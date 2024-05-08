terraform {
#  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"
   source = "../../../../modules/aws-codecommit/"
}



include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load common variables shared across all accounts
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))

  # Extract the name prefix for easy access
  name_prefix = local.common_vars.locals.name_prefix

  

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract the region for easy access
  aws_region = local.region_vars.locals.aws_region
}

generate "tfvars" {
  path              = "terragrunt.auto.tfvars"
  if_exists         = "overwrite"
  disable_signature = true
  contents          = <<-EOF
    repositories = [
      {
        name = "awsctl"
        tag = {
          Environment = "Shared"
          Project     = "CSCAF"
        }
      },
      {
        name = "aim-be"
        tag = {
          Environment = "APPV1Dev"
          Project        = "aim"
        }
      },
      {
        name = "aim_crm"
        tag = {
          Environment = "APPV1Dev"
          Project        = "aim"
        }
      },
      {
        name = "aim_data"
        tag = {
          Environment = "APPV1Dev"
          Project        = "aim"
        }
      },
      {
        name = "aim_mbl"
        tag = {
          Environment = "APPV1Dev"
          Project        = "aim"
        }
      },
      {
        name = "aimee_cdk_app"
        tag = {
          Environment = "APPV1Dev"
          Project        = "aim"
        }
      },
      {
        name = "aim_ml"
        tag = {
          Environment = "APPV1Dev"
          Project        = "aim"
        }
      },
      {
        name = "aiime-be-lambdas"
        tag = {
          Environment = "APPV1Dev"
          Project        = "aim"
        }
      },
      {
        name = "aim_crm_be"
        tag = {
          Environment = "APPV1Dev"
          Project        = "aim"
        }
      }
  ]
EOF
}


