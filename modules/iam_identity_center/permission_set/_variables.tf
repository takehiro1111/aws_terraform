# variable "create_permissions_boundary_attachment" {
#   description = "PermissionSetでアタッチするポリシーの実行可能な範囲を定義"
#   type = bool
#   default = true
# }

# variable "customer_managed_policy" {
#   description = "PermissionSetにマネージドポリシーをアタッチする場合はtrue"
#   type = string
#   default = true
# }

# variable "managed_policy_arn" {
#   description = "PermissionSetでアタッチするポリシーの実行可能な範囲を定義"
#   type = string
#   default = "arn:aws:iam::aws:policy/AdministratorAccess"
# }

# variable "create_permissions_boundary_attachment" {
#   description = "PermissionSetにカスタマー管理ドポリシーをアタッチする場合はtrue"
#   type = bool
#   default = true
# }

# variable "permission_sets" {
#   description = "Permission sets configuration"
#   type = map(object({
#     name                     = string
#     description             = string
#     session_duration        = string
#     permissions_boundary_arn = optional(string)
#     managed_policy_arns     = optional(string)
#     customer_managed_policy = optional(object({
#       path = optional(string, "/")
#     }))
#   }))
# }

# variable "create_customer_managed_policy" {
#   description = "カスタマー管理ポリシーの作成可否"
#   type = bool
#   default = false
# }

# variable "customer_managed_policy" {
#   description = "カスタマー管理ポリシー"
#   type = map(object({
#     name                     = string
#     description             = string
#     policy_statement  = list(any)
#   }))
# }

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
      description      = string
      path = optional(string, "/")
      policy_statement = list(any)
    }))
  }))
}

# variable "customer_managed_policy" {
#   description = "Customer managed policies for permission sets"
#   type = map(object({
#     name             = string
#     description      = string
#     path = optional(string, "/")
#     policy_statement = list(any)
#   }))
#   default = {}
# }

variable "attach_permissions_boundary" {
  description = "Attach permissions boundary to permission sets"
  type        = bool
  default     = true
}

variable "attach_aws_managed_policy" {
  description = "Attach AWS managed policy to permission sets"
  type        = bool
  default     = true
}

variable "attach_customer_managed_policy" {
  description = "Attach customer managed policy to permission sets"
  type        = bool
  default     = false
}
