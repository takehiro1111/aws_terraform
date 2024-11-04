variable "identity_store_arn" {
  description = "The identity store ID for AWS IAM Identity Center"
  type        = string
}

variable "identity_store_id" {
  description = "The identity store ID for AWS IAM Identity Center"
  type        = string
}

variable "permission_sets" {
  description = "Permission sets configuration"
  type = map(object({
    name                     = string
    description              = string
    permissions_boundary_arn = optional(string)
    managed_policy_arns      = optional(string)
    customer_managed_policy  = optional(object({
      name             = string
      path             = optional(string, "/")
    }))
  }))
}

variable "ssoadmin_account_assignment" {
  description = "aws_ssoadmin_account_assignment"
  type        = map(object({
    permission_set_arn = string
    principal_id = string
    account_id = string
  }))
}
