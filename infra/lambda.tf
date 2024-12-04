resource "aws_lambda_function" "daily_cost_notification" {
  function_name    = "${local.name_prefix}-daily-cost-notification"
  package_type     = "Image"
  image_uri        = "${aws_ecr_repository.lambda_repository.repository_url}:latest"
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = base64sha256(data.aws_s3_object.lambda_image_hash.body)
  environment {
    variables = {
      SLACK_WEBHOOK_URL = data.aws_ssm_parameter.slack_webhook_url.value
    }
  }
  depends_on = [aws_cloudwatch_log_group.lambda_log]
}

resource "null_resource" "lambda_build" {
  depends_on = [
    aws_s3_bucket.lambda_bucket,
    aws_ecr_repository.lambda_repository
  ]

  triggers = {
    code_diff = sha256(join("", [
      for file in fileset(local.golang_codedir, "*")
      : filesha256("${local.golang_codedir}/${file}")
    ]))
  }

  provisioner "local-exec" {
    command = <<EOF
      set -e
      cd ${path.module}/..
      
      echo "Building Docker image..."
      docker build . -f docker/Dockerfile --platform linux/amd64 -t ${aws_ecr_repository.lambda_repository.repository_url}:latest
      
      echo "Logging in to ECR..."
      aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.lambda_repository.repository_url}
      
      echo "Pushing image to ECR..."
      docker push ${aws_ecr_repository.lambda_repository.repository_url}:latest
      
      echo "Generating hash..."
      docker inspect --format='{{index .RepoDigests 0}}' ${aws_ecr_repository.lambda_repository.repository_url}:latest > ${local.hash_file_name}
      
      echo "Uploading hash to S3..."
      aws s3 cp ${local.hash_file_name} s3://${local.s3_base_path}/${local.hash_file_name} --content-type "text/plain"
    EOF
  }
}

