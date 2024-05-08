output "shared_codebuild_role_arn" {
  value = aws_iam_role.codebuild_service_role.arn
}