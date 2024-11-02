variable "identity_store_id" {
  type        = string
  description = "The identity store ID for AWS IAM Identity Center"
}

variable "groups" {
  type        = map(object({
    name        = string
    description = string
  }))
  description = "Map of groups to create in the identity store"
}

variable "users" {
  type = map(object({
    name = object({
      given_name  = string
      family_name = string
    })
  }))
  description = "Map of users to create in the identity store"
}

variable "users_groups_membership" {
  type        = map(object({ group = string, user = string }))
  description = "Map of user-group memberships to create in the identity store"
}
