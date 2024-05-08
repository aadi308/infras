# ##############################################
# ### CODECOMMIT VARIABLES
# ##############################################

# variable "create_new_repo" {
#   type        = bool
#   description = "Deciding a new repository needs to be created"
#   default     = false
# }

# variable "source_repository_name" {
#   type        = string
#   description = "Name of the Source CodeCommit repository used by the pipeline"
# }

# variable "source_repository_branch" {
#   type        = string
#   description = "Branch of the Source CodeCommit repository used in pipeline"
# }

# ##############################################
# ### CODEBUILD VARIABLES
# ##############################################

# variable "build_project_name" {
#   type = string
#   description = "Name of the project given by User"
# }

# variable "builder_compute_type" {
#   type = string
#   description = "Information about the compute resoureces the build project will use"
# }

# variable "builder_image" {
#   type = string
#   description = "Docker image to use for the build project"
# }

# variable "builder_type" {
#   type = string
#   description = "Type of the build environment to tuse for related builds"
# }

# #########################################################
# ### CODEPIPELINE
# #########################################################
# variable "codepipeline_name" {
#   type = string
#   description = "name of the codepipeline"
# }

# variable "s3_bucket_name" {
#   type = string
#   description = "codepipeline to store artifacts in bucket"
# }


##############################################
### CODECOMMIT VARIABLES
##############################################

variable "create_new_repo" {
  type        = bool
  description = "Deciding a new repository needs to be created"
  default     = false
}

# variable "source_repository_name" {
#   type        = string
#   description = "Name of the Source CodeCommit repository used by the pipeline"
# }
variable "repository_name" {
  type        = string
  description = "Name of the Source CodeCommit repository used by the pipeline"
}


variable "source_repository_branch" {
  type        = string
  description = "Branch of the Source CodeCommit repository used in pipeline"
}

##############################################
### CODEBUILD VARIABLES
##############################################

variable "code_build_role_name" {
  type = string
  description = "CodebuildRoleName"
}

// Shared account that will assume role created in stage account to access S3 Bucket
variable "account_id" {
  type = number
  description = "Account ID of Accounts"
}


variable "build_project_name" {
  type = string
  description = "Name of the project given by User"
}

variable "builder_compute_type" {
  type = string
  description = "Information about the compute resoureces the build project will use"
}

variable "builder_image" {
  type = string
  description = "Docker image to use for the build project"
}

variable "builder_type" {
  type = string
  description = "Type of the build environment to tuse for related builds"
}

#########################################################
### CODEPIPELINE
#########################################################
variable "codepipeline_name" {
  type = string
  description = "name of the codepipeline"
}

variable "codepipeline_role_name" {
  type = string
  description = "Codepipeline Role Name"
}

variable "s3_bucket_name" {
  type = string
  description = "codepipeline to store artifacts in bucket"
}