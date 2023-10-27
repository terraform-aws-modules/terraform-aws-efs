module "wrapper" {
  source = "../"

  for_each = var.items

  create                                = try(each.value.create, var.defaults.create, true)
  name                                  = try(each.value.name, var.defaults.name, "")
  tags                                  = try(each.value.tags, var.defaults.tags, {})
  availability_zone_name                = try(each.value.availability_zone_name, var.defaults.availability_zone_name, null)
  creation_token                        = try(each.value.creation_token, var.defaults.creation_token, null)
  performance_mode                      = try(each.value.performance_mode, var.defaults.performance_mode, null)
  encrypted                             = try(each.value.encrypted, var.defaults.encrypted, true)
  kms_key_arn                           = try(each.value.kms_key_arn, var.defaults.kms_key_arn, null)
  provisioned_throughput_in_mibps       = try(each.value.provisioned_throughput_in_mibps, var.defaults.provisioned_throughput_in_mibps, null)
  throughput_mode                       = try(each.value.throughput_mode, var.defaults.throughput_mode, null)
  lifecycle_policy                      = try(each.value.lifecycle_policy, var.defaults.lifecycle_policy, {})
  attach_policy                         = try(each.value.attach_policy, var.defaults.attach_policy, true)
  bypass_policy_lockout_safety_check    = try(each.value.bypass_policy_lockout_safety_check, var.defaults.bypass_policy_lockout_safety_check, null)
  source_policy_documents               = try(each.value.source_policy_documents, var.defaults.source_policy_documents, [])
  override_policy_documents             = try(each.value.override_policy_documents, var.defaults.override_policy_documents, [])
  policy_statements                     = try(each.value.policy_statements, var.defaults.policy_statements, [])
  deny_nonsecure_transport              = try(each.value.deny_nonsecure_transport, var.defaults.deny_nonsecure_transport, true)
  mount_targets                         = try(each.value.mount_targets, var.defaults.mount_targets, {})
  create_security_group                 = try(each.value.create_security_group, var.defaults.create_security_group, true)
  security_group_name                   = try(each.value.security_group_name, var.defaults.security_group_name, null)
  security_group_description            = try(each.value.security_group_description, var.defaults.security_group_description, null)
  security_group_use_name_prefix        = try(each.value.security_group_use_name_prefix, var.defaults.security_group_use_name_prefix, false)
  security_group_vpc_id                 = try(each.value.security_group_vpc_id, var.defaults.security_group_vpc_id, null)
  security_group_rules                  = try(each.value.security_group_rules, var.defaults.security_group_rules, {})
  access_points                         = try(each.value.access_points, var.defaults.access_points, {})
  create_backup_policy                  = try(each.value.create_backup_policy, var.defaults.create_backup_policy, true)
  enable_backup_policy                  = try(each.value.enable_backup_policy, var.defaults.enable_backup_policy, true)
  create_replication_configuration      = try(each.value.create_replication_configuration, var.defaults.create_replication_configuration, false)
  replication_configuration_destination = try(each.value.replication_configuration_destination, var.defaults.replication_configuration_destination, {})

}
