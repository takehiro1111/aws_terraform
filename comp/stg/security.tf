data "aws_kms_key" "key_for_rds" {
  key_id = "alias/aws/rds"
}
