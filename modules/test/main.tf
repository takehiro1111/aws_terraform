data "aws_ec2_managed_prefix_list" "cdn" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

output "test_id" {
  value = data.aws_ec2_managed_prefix_list.cdn.id
}
