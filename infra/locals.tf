locals {
  project_name        = "cost-notifier"
  name_prefix         = "${local.project_name}-${var.env}"
  s3_bucket           = "${local.name_prefix}-${random_string.bucket_suffix.result}"
  s3_key_prefix       = "lambda"
  s3_base_path        = "${local.s3_bucket}/${local.s3_key_prefix}"
  golang_codedir      = "${path.module}/../src"
  hash_file_name      = "image_digest.txt"
  ecr_repository_name = "${local.name_prefix}-lambda"
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}
