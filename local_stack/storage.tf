resource "aws_s3_bucket" "local_stack" {
  for_each = toset([
    "s3-localstack",
    "s3-localstack-2",
  ])
  bucket = each.key
}
