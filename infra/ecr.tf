resource "aws_ecr_repository" "lambda_repository" {
  name = local.ecr_repository_name
}
