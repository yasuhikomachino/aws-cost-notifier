resource "aws_s3_bucket" "lambda_bucket" {
  bucket = local.s3_bucket
}

resource "aws_s3_bucket_ownership_controls" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

data "aws_s3_object" "lambda_image_hash" {
  depends_on = [null_resource.lambda_build]

  bucket = local.s3_bucket
  key    = "${local.s3_key_prefix}/${local.hash_file_name}"
}
