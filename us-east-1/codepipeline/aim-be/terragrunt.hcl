terraform {
  source = "../../../../../modules/codepipeline/"

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
   
    #########################################################
    ### CODECOMMIT
    #########################################################

    create_new_repo = false
    repository_name = "aim-be"
    source_repository_branch = "main"

    #########################################################
    ### CODEBUILD
    #########################################################
    code_build_role_name = "aim-be-codebuild-role"
    build_project_name = "aim-be-codebuild"
    builder_compute_type = "BUILD_GENERAL1_SMALL"
    builder_image = "aws/codebuild/standard:5.0"
    builder_type = "LINUX_CONTAINER"


    #########################################################
    ### CODEPIPELINE
    #########################################################
    
    # Account ID of Dev Account that will let shared account
    # assume a role created in Dev Account
    account_id = 474280631061

    codepipeline_name = "aim-be-codepipeline"
    codepipeline_role_name = "aim-be-codepipeline-role"
    s3_bucket_name = "aim-be-codepipeline-artifacts"
    
EOF
}













