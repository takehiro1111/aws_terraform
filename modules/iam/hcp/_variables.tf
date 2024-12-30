variable "hcp_org_name" {
  description = "IAMのConditionで定義するHCP TerraformのOrganization名"
  type        = string
  default     = "takehiro1111"

  validation {
    condition     = length(var.hcp_org_name) > 0
    error_message = "HCP organization name must not be empty."
  }
}
