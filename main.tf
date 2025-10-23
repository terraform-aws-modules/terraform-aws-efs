################################################################################
# File System
################################################################################

resource "aws_efs_file_system" "this" {
  count = var.create ? 1 : 0

  availability_zone_name          = var.availability_zone_name
  creation_token                  = var.creation_token
  performance_mode                = var.performance_mode
  encrypted                       = var.encrypted
  kms_key_id                      = var.kms_key_arn
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode

  dynamic "lifecycle_policy" {
    for_each = { for k, v in var.lifecycle_policy : k => v if v != null }

    content {
      transition_to_ia                    = lifecycle_policy.key == "transition_to_ia" ? lifecycle_policy.value : null
      transition_to_archive               = lifecycle_policy.key == "transition_to_archive" ? lifecycle_policy.value : null
      transition_to_primary_storage_class = lifecycle_policy.key == "transition_to_primary_storage_class" ? lifecycle_policy.value : null
    }
  }

  dynamic "protection" {
    for_each = var.protection != null ? [var.protection] : []
    content {
      replication_overwrite = protection.value.replication_overwrite
    }
  }

  tags = merge(
    var.tags,
    { Name = var.name },
  )
}

################################################################################
# File System Policy
################################################################################

data "aws_iam_policy_document" "policy" {
  count = var.create && var.attach_policy ? 1 : 0

  source_policy_documents   = var.source_policy_documents
  override_policy_documents = var.override_policy_documents

  dynamic "statement" {
    for_each = var.policy_statements != null ? var.policy_statements : {}

    content {
      sid           = coalesce(statement.value.sid, statement.key)
      actions       = statement.value.actions
      not_actions   = statement.value.not_actions
      effect        = statement.value.effect
      resources     = statement.value.resources != null ? statement.value.resources : [aws_efs_file_system.this[0].arn]
      not_resources = statement.value.not_resources

      dynamic "principals" {
        for_each = statement.value.principals != null ? statement.value.principals : []

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = statement.value.not_principals != null ? statement.value.not_principals : []

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.condition != null ? statement.value.condition : []

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }

  dynamic "statement" {
    for_each = var.deny_nonsecure_transport ? [1] : []

    content {
      sid       = "NonSecureTransport"
      effect    = "Deny"
      actions   = ["*"]
      resources = [aws_efs_file_system.this[0].arn]

      principals {
        type        = "AWS"
        identifiers = ["*"]
      }

      condition {
        test     = "Bool"
        variable = "aws:SecureTransport"
        values   = ["false"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.deny_nonsecure_transport_via_mount_target ? [1] : []

    content {
      sid    = "NonSecureTransportAccessedViaMountTarget"
      effect = "Allow"
      actions = [
        "elasticfilesystem:ClientRootAccess",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:ClientMount"
      ]
      resources = [aws_efs_file_system.this[0].arn]

      principals {
        type        = "AWS"
        identifiers = ["*"]
      }

      condition {
        test     = "Bool"
        variable = "elasticfilesystem:AccessedViaMountTarget"
        values   = ["true"]
      }
    }
  }
}

resource "aws_efs_file_system_policy" "this" {
  count = var.create && var.attach_policy ? 1 : 0

  file_system_id                     = aws_efs_file_system.this[0].id
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  policy                             = data.aws_iam_policy_document.policy[0].json
}

################################################################################
# Mount Target(s)
################################################################################

resource "aws_efs_mount_target" "this" {
  for_each = { for k, v in var.mount_targets : k => v if var.create }

  file_system_id  = aws_efs_file_system.this[0].id
  ip_address      = each.value.ip_address
  ip_address_type = each.value.ip_address_type
  ipv6_address    = each.value.ipv6_address
  region          = var.region
  security_groups = var.create_security_group ? concat([aws_security_group.this[0].id], each.value.security_groups) : each.value.security_groups
  subnet_id       = each.value.subnet_id
}

################################################################################
# Security Group
################################################################################

locals {
  security_group_name = try(coalesce(var.security_group_name, var.name), "")

  create_security_group = var.create && var.create_security_group && length(var.mount_targets) > 0
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  name        = var.security_group_use_name_prefix ? null : local.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.security_group_name}-" : null
  description = var.security_group_description

  revoke_rules_on_delete = true
  vpc_id                 = var.security_group_vpc_id

  tags = merge(
    var.tags,
    { Name = local.security_group_name },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = { for k, v in var.security_group_ingress_rules : k => v if var.security_group_ingress_rules != null && local.create_security_group }

  region = var.region

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = each.value.from_port
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id == "self" ? aws_security_group.this[0].id : each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  tags = merge(
    var.tags,
    { "Name" = coalesce(each.value.name, "${local.security_group_name}-${each.key}") },
    each.value.tags
  )
  to_port = try(coalesce(each.value.to_port, each.value.from_port), null)
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = { for k, v in var.security_group_egress_rules : k => v if var.security_group_egress_rules != null && local.create_security_group }

  region = var.region

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = try(coalesce(each.value.from_port, each.value.to_port), null)
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id == "self" ? aws_security_group.this[0].id : each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  tags = merge(
    var.tags,
    { "Name" = coalesce(each.value.name, "${local.security_group_name}-${each.key}") },
    each.value.tags
  )
  to_port = each.value.to_port
}

################################################################################
# Access Point(s)
################################################################################

resource "aws_efs_access_point" "this" {
  for_each = { for k, v in var.access_points : k => v if var.create }

  file_system_id = aws_efs_file_system.this[0].id

  dynamic "posix_user" {
    for_each = each.value.posix_user != null ? [each.value.posix_user] : []

    content {
      gid            = posix_user.value.gid
      uid            = posix_user.value.uid
      secondary_gids = posix_user.value.secondary_gids
    }
  }

  dynamic "root_directory" {
    for_each = each.value.root_directory != null ? [each.value.root_directory] : []

    content {
      path = root_directory.value.path

      dynamic "creation_info" {
        for_each = root_directory.value.creation_info != null ? [root_directory.value.creation_info] : []

        content {
          owner_gid   = creation_info.value.owner_gid
          owner_uid   = creation_info.value.owner_uid
          permissions = creation_info.value.permissions
        }
      }
    }
  }

  tags = merge(
    var.tags,
    each.value.tags,
    { Name = each.value.name != null ? each.value.name : each.key },
  )
}

################################################################################
# Backup Policy
################################################################################

resource "aws_efs_backup_policy" "this" {
  count = var.create && var.create_backup_policy ? 1 : 0

  file_system_id = aws_efs_file_system.this[0].id

  backup_policy {
    status = var.enable_backup_policy ? "ENABLED" : "DISABLED"
  }
}

################################################################################
# Replication Configuration
################################################################################

resource "aws_efs_replication_configuration" "this" {
  count = var.create && var.create_replication_configuration ? 1 : 0

  source_file_system_id = aws_efs_file_system.this[0].id

  dynamic "destination" {
    for_each = var.replication_configuration_destination != null ? [var.replication_configuration_destination] : []

    content {
      availability_zone_name = destination.value.availability_zone_name
      file_system_id         = destination.value.file_system_id
      kms_key_id             = destination.value.kms_key_id
      region                 = destination.value.region
    }
  }
}
