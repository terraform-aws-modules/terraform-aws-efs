# Wrapper for the root module

The configuration in this directory contains an implementation of a single module wrapper pattern, which allows managing several copies of a module in places where using the native Terraform 0.13+ `for_each` feature is not feasible (e.g., with Terragrunt).

You may want to use a single Terragrunt configuration file to manage multiple resources without duplicating `terragrunt.hcl` files for each copy of the same module.

This wrapper does not implement any extra functionality.

## Usage with Terragrunt

`terragrunt.hcl`:

```hcl
terraform {
  source = "tfr:///terraform-aws-modules/efs/aws//wrappers"
  # Alternative source:
  # source = "git::git@github.com:terraform-aws-modules/terraform-aws-efs.git//wrappers?ref=master"
}

inputs = {
  defaults = { # Default values
    create = true
    tags = {
      Terraform   = "true"
      Environment = "dev"
    }
  }

  items = {
    my-item = {
      # omitted... can be any argument supported by the module
    }
    my-second-item = {
      # omitted... can be any argument supported by the module
    }
    # omitted...
  }
}
```

## Usage with Terraform

```hcl
module "wrapper" {
  source = "terraform-aws-modules/efs/aws//wrappers"

  defaults = { # Default values
    create = true
    tags = {
      Terraform   = "true"
      Environment = "dev"
    }
  }

  items = {
    my-item = {
      # omitted... can be any argument supported by the module
    }
    my-second-item = {
      # omitted... can be any argument supported by the module
    }
    # omitted...
  }
}
```

## Example: Manage multiple EFS resources in one Terragrunt layer

`eu-west-1/efs/terragrunt.hcl`:

```hcl
terraform {
  source = "tfr:///terraform-aws-modules/efs/aws//wrappers"
  # Alternative source:
  # source = "git::git@github.com:terraform-aws-modules/terraform-aws-efs.git//wrappers?ref=master"
}

inputs = {
  defaults = {
    create = true

    attach_policy                      = true
    bypass_policy_lockout_safety_check = false
    
    performance_mode                = "maxIO"
    throughput_mode                 = "provisioned"
    provisioned_throughput_in_mibps = 256

    encrypted      = true

    lifecycle_policy = {
      transition_to_ia = "AFTER_30_DAYS"
    }
    
    attach_policy                      = true
    bypass_policy_lockout_safety_check = false

    tags = {
      Terraform   = "true"
      Environment = "dev"
    }
  }

  items = {
    efs1 = {
      name           = "example1"
      creation_token = "example-token1"
      kms_key_arn    = "arn:aws:kms:eu-west-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
      policy_statements = [
        {
          sid     = "Example1"
          actions = ["elasticfilesystem:ClientMount"]
          principals = [
            {
              type        = "AWS"
              identifiers = ["arn:aws:iam::111122223333:role/EfsReadOnly"]
            }
          ]
        }
      ]
      mount_targets = {
        "eu-west-1a" = {
          subnet_id = "subnet-abcde012"
        }
        "eu-west-1b" = {
          subnet_id = "subnet-bcde012a"
        }
        "eu-west-1c" = {
          subnet_id = "subnet-fghi345a"
        }
      }
      security_group_description = "Example EFS security group"
      security_group_vpc_id      = "vpc-1234556abcdef"
      security_group_rules = {
        vpc = {
          # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
          description = "NFS ingress from VPC private subnets"
          cidr_blocks = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
        }
      }
      access_points = {
        posix_example = {
          name = "posix-example"
          posix_user = {
            gid            = 1001
            uid            = 1001
            secondary_gids = [1002]
          }
          tags = {
            Additionl = "yes"
          }
        }
        root_example = {
          root_directory = {
            path = "/example"
            creation_info = {
              owner_gid   = 1001
              owner_uid   = 1001
              permissions = "755"
            }
          }
        }
      }
      enable_backup_policy = true
      create_replication_configuration = true
      replication_configuration_destination = {
        region = "eu-west-2"
      }
    }
    efs2 = {
      name           = "example2"
      creation_token = "example-token2"
      kms_key_arn    = "arn:aws:kms:eu-west-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ac"
      policy_statements = [
        {
          sid     = "Example2"
          actions = ["elasticfilesystem:ClientMount"]
          principals = [
            {
              type        = "AWS"
              identifiers = ["arn:aws:iam::111122223333:role/EfsWrite"]
            }
          ]
        }
      ]
    }
  }
}
```
