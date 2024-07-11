output "s3_bucket" {
  description = "ログの吐き出し元の設定で参照する。"
  value = aws_s3_bucket.this.bucket
}
