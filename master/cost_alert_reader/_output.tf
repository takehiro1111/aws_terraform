output "iam_role_arn_reader" {
  description = "development の Lambda が AssumeRole する Cost Explorer 読み取りロール"
  value       = aws_iam_role.reader.arn
}
