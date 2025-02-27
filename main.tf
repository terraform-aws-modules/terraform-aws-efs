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
    for_each = [for k, v in var.lifecycle_policy : { (k) = v }]

    content {
      transition_to_ia                    = try(lifecycle_policy.value.transition_to_ia, null)
      transition_to_archive               = try(lifecycle_policy.value.transition_to_archive, null)
      transition_to_primary_storage_class = try(lifecycle_policy.value.transition_to_primary_storage_class, null)
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
    for_each = var.policy_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, [aws_efs_file_system.this[0].arn], null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, statement.value.condition, [])

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
  ip_address      = try(each.value.ip_address, null)
  security_groups = var.create_security_group ? concat([aws_security_group.this[0].id], try(each.value.security_groups, [])) : try(each.value.security_groups, null)
  subnet_id       = each.value.subnet_id
}

################################################################################
# Security Group
################################################################################

locals {
  security_group_name = try(coalesce(var.security_group_name, var.name), "")

  create_security_group = var.create && var.create_security_group && length(var.mount_targets) > 0
  egress_rules_ipv4 = flatten([
    for rule in var.security_group_rules : [
      for cidr_block in try(rule.cidr_blocks, []) : {
        description                  = try(rule.description, null)
        from_port                    = try(rule.from_port, 2049)
        to_port                      = try(rule.to_port, 2049)
        ip_protocol                  = try(rule.protocol, "tcp")
        prefix_list_id               = lookup(rule, "prefix_list_ids", null)
        referenced_security_group_id = lookup(rule, "source_security_group_id", null)
        from_port                    = try(rule.from_port, 2049)
        to_port                      = try(rule.to_port, 2049)
        protocol                     = try(rule.protocol, "tcp")
        cidr_ipv4                    = cidr_block
      }
    ] if try(rule.type, "egress") == "egress" && try(rule.ipv6_cidr_blocks, null) == null
  ])
  egress_rules_ipv6 = flatten([
    for rule in var.security_group_rules : [
      for cidr_block in try(rule.ipv6_cidr_blocks, []) : {
        description                  = try(rule.description, null)
        from_port                    = try(rule.from_port, 2049)
        to_port                      = try(rule.to_port, 2049)
        ip_protocol                  = try(rule.protocol, "tcp")
        prefix_list_id               = lookup(rule, "prefix_list_ids", null)
        referenced_security_group_id = lookup(rule, "source_security_group_id", null)
        from_port                    = try(rule.from_port, 2049)
        to_port                      = try(rule.to_port, 2049)
        protocol                     = try(rule.protocol, "tcp")
        cidr_ipv6                    = cidr_block
      }
    ] if try(rule.type, "egress") == "egress" && try(rule.cidr_block, null) == null
  ])
  egress_rules = concat(local.egress_rules_ipv4, local.egress_rules_ipv6)

  ingress_rules_ipv4 = flatten([
    for rule in var.security_group_rules : [
      for cidr_block in try(rule.cidr_blocks, []) : {
        description                  = try(rule.description, null)
        from_port                    = try(rule.from_port, 2049)
        to_port                      = try(rule.to_port, 2049)
        ip_protocol                  = try(rule.protocol, "tcp")
        prefix_list_id               = lookup(rule, "prefix_list_ids", null)
        referenced_security_group_id = lookup(rule, "source_security_group_id", null)
        from_port                    = try(rule.from_port, 2049)
        to_port                      = try(rule.to_port, 2049)
        protocol                     = try(rule.protocol, "tcp")
        cidr_ipv4                    = cidr_block
      }
    ] if try(rule.type, "ingress") == "ingress" && try(rule.ipv6_cidr_blocks, null) == null
  ])
  ingress_rules_ipv6 = flatten([
    for rule in var.security_group_rules : [
      for cidr_block in try(rule.ipv6_cidr_blocks, []) : {
        description                  = try(rule.description, null)
        from_port                    = try(rule.from_port, 2049)
        to_port                      = try(rule.to_port, 2049)
        ip_protocol                  = try(rule.protocol, "tcp")
        prefix_list_id               = lookup(rule, "prefix_list_ids", null)
        referenced_security_group_id = lookup(rule, "source_security_group_id", null)
        from_port                    = try(rule.from_port, 2049)
        to_port                      = try(rule.to_port, 2049)
        protocol                     = try(rule.protocol, "tcp")
        cidr_ipv6                    = cidr_block
      }
    ] if try(rule.type, "ingress") == "ingress" && try(rule.cidr_block, null) == null
  ])
  ingress_rules = concat(local.ingress_rules_ipv4, local.ingress_rules_ipv6)
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  name        = var.security_group_use_name_prefix ? null : local.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.security_group_name}-" : null
  description = var.security_group_description

  revoke_rules_on_delete = true
  vpc_id                 = var.security_group_vpc_id

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = { for idx, rule in local.egress_rules : idx => rule }

  security_group_id = aws_security_group.this[0].id

  description = try(each.value.description, null)
  from_port   = try(each.value.from_port, 2049)
  to_port     = try(each.value.to_port, 2049)
  ip_protocol = try(each.value.ip_protocol, "tcp")
  cidr_ipv4   = try(each.value.cidr_ipv4, null) != null ? each.value.cidr_ipv4 : null
  cidr_ipv6   = try(each.value.cidr_ipv6, null) != null ? each.value.cidr_ipv6 : null
  # prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = aws_security_group.this[0].id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = { for idx, rule in local.ingress_rules : idx => rule }

  security_group_id = aws_security_group.this[0].id

  description = try(each.value.description, null)
  from_port   = try(each.value.from_port, 2049)
  to_port     = try(each.value.to_port, 2049)
  ip_protocol = try(each.value.ip_protocol, "tcp")
  cidr_ipv4   = try(each.value.cidr_ipv4, null) != null ? each.value.cidr_ipv4 : null
  cidr_ipv6   = try(each.value.cidr_ipv6, null) != null ? each.value.cidr_ipv6 : null
  # prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = aws_security_group.this[0].id

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Access Point(s)
################################################################################

resource "aws_efs_access_point" "this" {
  for_each = { for k, v in var.access_points : k => v if var.create }

  file_system_id = aws_efs_file_system.this[0].id

  dynamic "posix_user" {
    for_each = try([each.value.posix_user], [])

    content {
      gid            = posix_user.value.gid
      uid            = posix_user.value.uid
      secondary_gids = try(posix_user.value.secondary_gids, null)
    }
  }

  dynamic "root_directory" {
    for_each = try([each.value.root_directory], [])

    content {
      path = try(root_directory.value.path, null)

      dynamic "creation_info" {
        for_each = try([root_directory.value.creation_info], [])

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
    try(each.value.tags, {}),
    { Name = try(each.value.name, each.key) },
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
    for_each = [var.replication_configuration_destination]

    content {
      availability_zone_name = try(destination.value.availability_zone_name, null)
      kms_key_id             = try(destination.value.kms_key_id, null)
      region                 = try(destination.value.region, null)
    }
  }
}
