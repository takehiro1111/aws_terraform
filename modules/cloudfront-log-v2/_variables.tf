################################################################################
# Cloudwatch log delivery (For Cloudfront)
################################################################################
variable "delivery_destination_arn" {
  type        = string
  description = "Cloudfrontにおけるログの転送先ARN"
}

variable "cloudfront_distributions" {
  description = "List of CloudFront distributions to create delivery sources for"
  type = list(object({
    name         = string
    resource_arn = string
    record_fields = optional(list(string), [
      "timestamp",
      # "DistributionId",
      "date",
      "time",
      "x-edge-location",
      "sc-bytes",
      "c-ip",
      "cs-method",
      "cs(Host)",
      "cs-uri-stem",
      "sc-status",
      "cs(Referer)",
      "cs(User-Agent)",
      "cs-uri-query",
      "cs(Cookie)",
      "x-edge-result-type",
      "x-edge-request-id",
      "x-host-header",
      "cs-protocol",
      "cs-bytes",
      "time-taken",
      "x-forwarded-for",
      "ssl-protocol",
      "ssl-cipher",
      "x-edge-response-result-type",
      "cs-protocol-version",
      "fle-status",
      "fle-encrypted-fields",
      "c-port",
      "time-to-first-byte",
      "x-edge-detailed-result-type",
      "sc-content-type",
      "sc-content-len",
      "sc-range-start",
      "sc-range-end"
      # "timestamp(ms)",
      # "origin-fbl",
      # "origin-lbl",
      # "asn",
      # "c-country",
      # "cache-behavior-path-pattern",
    ])
  }))
}
