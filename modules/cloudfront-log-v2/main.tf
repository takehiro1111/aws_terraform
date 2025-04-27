################################################################################
# Cloudwatch log delivery (For Use Cloudfront Account)
################################################################################
resource "aws_cloudwatch_log_delivery_source" "this" {
  for_each = {
    for idx, dist in var.cloudfront_distributions : dist.name => dist
  }

  name         = "CloudFront-${each.value.name}"
  log_type     = "ACCESS_LOGS"
  resource_arn = each.value.resource_arn
}

resource "awscc_logs_delivery" "this" {
  for_each = {
    for idx, dist in var.cloudfront_distributions : dist.name => dist
  }

  delivery_source_name     = aws_cloudwatch_log_delivery_source.this[each.key].name
  delivery_destination_arn = var.delivery_destination_arn
  record_fields            = each.value.record_fields
}
