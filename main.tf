################################################################################
# File System
################################################################################

resource "aws_efs_file_system" "this" {
  count = var.create ? 1 : 0

  availability_zone_name          = var.availability_zone_name
  creation_token                  = var.creation_token
  performance_mode                = var.performance_mode
  encrypted                       = var.encrypted
  kms_key_id                      = var.kms_key_id
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode

  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy

    content {
      transition_to_ia                    = try(lifecycle_policy.value.transition_to_ia, null)
      transition_to_primary_storage_class = try(lifecycle_policy.value.transition_to_primary_storage_class, null)
    }
  }

  tags = var.tags
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
      resources     = try(statement.value.resources, null)
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
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }

  statement {
    sid     = "NonSecureTransport"
    effect  = "Deny"
    actions = ["*"]

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

resource "aws_security_group" "this" {
  count = var.create && var.create_security_group ? 1 : 0

  name        = var.security_group_use_name_prefix ? null : var.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${var.security_group_name}-" : null
  description = var.security_group_description

  revoke_rules_on_delete = true
  vpc_id                 = var.security_group_vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "this" {
  for_each = { for k, v in var.security_group_rules : k => v if var.create && var.create_security_group }

  security_group_id = aws_security_group.this[0].id

  type                     = try(each.value.type, "ingress")
  from_port                = try(each.value.from_port, 2049)
  to_port                  = try(each.value.to_port, 2049)
  protocol                 = try(each.value.protocol, "tcp")
  cidr_blocks              = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, null)
  prefix_list_ids          = try(each.value.prefix_list_ids, null)
  self                     = try(each.value.self, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
}
