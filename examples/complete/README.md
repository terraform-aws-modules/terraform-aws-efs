# Complete AWS EFS Example

Configuration in this directory creates:

- A "complete" EFS file system which demonstrates the various configurations that are supported by the module
- A "default" EFS file system which demonstrates the default configurations provided by the module
- A disabled EFS file system

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which will incur monetary charges on your AWS bill. Run `terraform destroy` when you no longer need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.35 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.35 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_efs"></a> [efs](#module\_efs) | ../.. | n/a |
| <a name="module_efs_default"></a> [efs\_default](#module\_efs\_default) | ../.. | n/a |
| <a name="module_efs_disabled"></a> [efs\_disabled](#module\_efs\_disabled) | ../.. | n/a |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-aws-modules/kms/aws | ~> 1.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_points"></a> [access\_points](#output\_access\_points) | Map of access points created and their attributes |
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name of the file system |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | The DNS name for the filesystem per [documented convention](http://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html) |
| <a name="output_id"></a> [id](#output\_id) | The ID that identifies the file system (e.g., `fs-ccfc0d65`) |
| <a name="output_mount_targets"></a> [mount\_targets](#output\_mount\_targets) | Map of mount targets created and their attributes |
| <a name="output_replication_configuration_destination_file_system_id"></a> [replication\_configuration\_destination\_file\_system\_id](#output\_replication\_configuration\_destination\_file\_system\_id) | The file system ID of the replica |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | ARN of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
| <a name="output_size_in_bytes"></a> [size\_in\_bytes](#output\_size\_in\_bytes) | The latest known metered size (in bytes) of data stored in the file system, the value is not the exact size that the file system was at any point in time |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-efs/blob/master/LICENSE).
