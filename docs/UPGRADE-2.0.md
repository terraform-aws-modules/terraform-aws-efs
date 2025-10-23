# Upgrade from v1.x to v2.x

Please consult the `examples` directory for reference example configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

## List of backwards incompatible changes

- Terraform `v1.5.7` is now minimum supported version
- AWS provider `v6.12` is now minimum supported version
- `security_group_rules` has been split into `security_group_ingress_rules` and `security_group_egress_rules` to better match the AWS API and allow for more flexibility in defining security group rules.
- `policy_statements` changed from type `any` to `map`

## Additional changes

### Added

- Support for `region` parameter to specify the AWS region for the resources created if different from the provider region.

### Modified

- Variable definitions now contain detailed `object` types in place of the previously used any type.

### Variable and output changes

1. Removed variables:

  - `security_group_rules`

2. Renamed variables:

  - None

3. Added variables:

  - `security_group_ingress_rules`
  - `security_group_egress_rules`

4. Removed outputs:

  - None

5. Renamed outputs:

  - None

6. Added outputs:

  - None

## Upgrade Migrations

### Before 2.x Example

```hcl
module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "~> 1.0"

  # Truncated for brevity ...

  # Security Groups
  security_group_rules = {
    vpc = {
      # relying on the defaults provided for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }
  
  # EFS Policy Statements 
  policy_statements = [
    {
      sid     = "Example"
      actions = ["elasticfilesystem:ClientMount"]
      principals = [
        {
          type        = "AWS"
          identifiers = [data.aws_caller_identity.current.arn]
        }
      ]
    }
  ]
}
```

### After 2.x Example

```hcl
module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "~> 2.0"

  # Truncated for brevity ...

  # Security Groups
  security_group_ingress_rules = {
    vpc_1 = {
      # relying on the defaults provided for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_ipv4   = element(module.vpc.private_subnets_cidr_blocks, 0)
    }
    vpc_2 = {
      # relying on the defaults provided for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_ipv4   = element(module.vpc.private_subnets_cidr_blocks, 1)
    }
    vpc_3 = {
      # relying on the defaults provided for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_ipv4   = element(module.vpc.private_subnets_cidr_blocks, 2)
    }
  }
  
  # EFS policy statements 
  policy_statements = {
    example = {
      sid     = "Example"
      actions = ["elasticfilesystem:ClientMount"]
      principals = [
        {
          type        = "AWS"
          identifiers = [data.aws_caller_identity.current.arn]
        }
      ]
    }
  }
}
```

### State Changes

Due to the change from `aws_security_group_rule` to `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule`, the following reference state changes are required to maintain the current security group rules. (Note: these are different resources so they cannot be moved with `terraform mv ...`)

```sh
terraform state rm 'module.efs.aws_security_group_rule.this["vpc"]'
terraform state import 'module.efs.aws_vpc_security_group_ingress_rule.this["vpc_1"]' 'sg-xxx'
terraform state import 'module.efs.aws_vpc_security_group_ingress_rule.this["vpc_2"]' 'sg-xxx'
terraform state import 'module.efs.aws_vpc_security_group_ingress_rule.this["vpc_3"]' 'sg-xxx'
```
