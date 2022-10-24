# Complete AWS EFS Example

Configuration in this directory creates:

- <XXX>

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.16 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_efs"></a> [efs](#module\_efs) | ../.. | n/a |
| <a name="module_efs_disabled"></a> [efs\_disabled](#module\_efs\_disabled) | ../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.0 |

## Resources

No resources.

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
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | ARN of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
| <a name="output_size_in_bytes"></a> [size\_in\_bytes](#output\_size\_in\_bytes) | The latest known metered size (in bytes) of data stored in the file system, the value is not the exact size that the file system was at any point in time |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-efs/blob/master/LICENSE).
