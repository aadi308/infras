
# Define environment variables for CodeBuild projects
locals {
  build_environment_variables = {
    ACTION = "BUILD"
  }
  deploy_environment_variables = {
    ACTION = "DEPLOY"
  }
}

#########################################################
### CODEBUILD
#########################################################

resource "aws_iam_role" "codebuild_service_role" {
  name = var.code_build_role_name

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }, 
    ]
  })
  inline_policy {
    name = "shared_codebuild_inline_policy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [

          {
            "Effect": "Allow",
            "Action": [
              "codebuild:BatchGetBuilds",
              "codebuild:StartBuild",
              "codebuild:BatchGetProjects",
              "codebuild:CreateReportGroup",
              "codebuild:CreateReport",
              "codebuild:UpdateReport",
              "codebuild:BatchPutTestCases",
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "s3:*",
              "ecr:*",
              "codecommit:GitPull"
            ],
            "Resource": "*"
          },
        ]
    })
  }
  inline_policy {
    name = "shared_to_assume_role_s3"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [ {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = "arn:aws:iam::${var.account_id}:role/*"
      }]
    })
  }
}

resource "aws_codebuild_project" "build_project" {
  name        = var.build_project_name
  service_role = aws_iam_role.codebuild_service_role.arn
  description = "CodeBuild project for my CodeCommit repo"
  build_timeout = 60

  source {
    type            = "CODECOMMIT"
    location        = var.repository_name
    buildspec       = "buildspec.yml" // Read buildspec.yml as default
    git_clone_depth = 1
  
  }
  source_version = ""
  
  environment {
    compute_type   = var.builder_compute_type
    image          = "aws/codebuild/standard:5.0" // Managed image
    type           = var.builder_type
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true // Enable privileged mode
  }
  artifacts {
    type = "NO_ARTIFACTS"
    name = null
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
      group_name = "/aws/codebuild/${var.build_project_name}"
    }
  }

}

#########################################################
### CODEPIPELINE
#########################################################

resource "aws_iam_role" "codepipeline_service_role" {
  name = var.codepipeline_role_name

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }, 
    ]
  })
  inline_policy {
    name = "shared_codebuild_policy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
          {
            "Action": [
              "iam:PassRole"
            ],
            "Resource": "*"
            "Effect": "Allow",
            "Condition" : {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "cloudformation.amazonaws.com",
                        "elasticbeanstalk.amazonaws.com",
                        "ec2.amazonaws.com",
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
          },
          {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetRepository",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
          }, 
          {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
          }, 
          {
            "Action": [
                "elasticbeanstalk:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "sqs:*",
                "ecs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
          }, 
          {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild",
                "codebuild:BatchGetBuildBatches",
                "codebuild:StartBuildBatch"
            ],
            "Resource": "*",
            "Effect": "Allow"
          }, 
          {
            "Effect": "Allow",
            "Action": [
                "ecr:DescribeImages"
            ],
            "Resource": "*"
          }, 
          {
            "Effect": "Allow",
            "Action": [
                "servicecatalog:ListProvisioningArtifacts",
                "servicecatalog:CreateProvisioningArtifact",
                "servicecatalog:DescribeProvisioningArtifact",
                "servicecatalog:DeleteProvisioningArtifact",
                "servicecatalog:UpdateProduct"
            ],
            "Resource": "*"
        },
        {
          "Action": [
              "codeartifact:GetAuthorizationToken",
              "codeartifact:GetRepositoryEndpoint",
              "codeartifact:ReadFromRepository",
              "sts:GetServiceBearerToken"
          ],
          "Resource": "*",
          "Effect": "Allow"
        }, 
        ]
    })
  }
  inline_policy {
    name = "shared_assume_role_s3"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [ {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = "arn:aws:iam::${var.account_id}:role/*"

        
      }]
    })
  }
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.s3_bucket_name
}


# AWS CodePipeline
resource "aws_codepipeline" "devops-codepipeline" {
  name     = var.codepipeline_name
  role_arn = aws_iam_role.codepipeline_service_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }
  
  stage {
    name = "source"

    action {
      name            = "Download-Source"
      category        = "Source"
      owner           = "AWS"
      provider        = "CodeCommit"
      version         = "1"
      namespace       = "SourceVariables"
      output_artifacts = ["SourceOutput"]
      run_order =  1

      configuration = {
        RepositoryName = var.repository_name
        BranchName     = "main"
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "build"

    action {
      name           = "Build"
      category       = "Build"
      owner          = "AWS"
      provider       = "CodeBuild"
      version        = "1"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]
      run_order      = 2

      configuration = {
        ProjectName     = aws_codebuild_project.build_project.name # CodeBuild deployment project name
        EnvironmentVariables = jsonencode([{
          name  = "ACTION"
          type  = "PLAINTEXT"
          value = "BUILD"
        }])
      }
    }
  }

  stage {
    name = "deploy"

    action {
      name           = "Deploy"
      category       = "Build"
      owner          = "AWS"
      provider       = "CodeBuild"
      version        = "1"
      input_artifacts  = ["BuildOutput"]
      run_order      = 3
      configuration = {
        ProjectName     = aws_codebuild_project.build_project.name # CodeBuild deployment project name
        EnvironmentVariables = jsonencode([{
          name  = "ACTION"
          type  = "PLAINTEXT"
          value = "DEPLOY"
        }])
      }
    }
  }
}
