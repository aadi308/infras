terraform {
  source = "../../../../modules/aws-ecr/"

}



include "root" {
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
        name            = "aim_crm_be-ecr"
        cross_account_role = "arn:aws:iam::474280631061:root"
        tags = {
          Name        = "aim_crm_be-ecr"
          Environment = "APPV1Dev"
          Project     = "CSCAF"
        }
      },
      {
        name            = "aim_be-ecr"
        cross_account_role = "arn:aws:iam::474280631061:root"
        tags = {
          Name        = "aim_be-ecr"
          Environment = "APPV1Dev"
          Project     = "CSCAF"
        }
      }
    ]
EOF
}