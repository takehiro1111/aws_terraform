variable "identity_store_id" {
  description = "The identity store ID for AWS IAM Identity Center"
  type        = string

}

variable "groups" {
  description = "Map of groups to create in the identity store"
  type = map(object({
    name        = string
    description = string
  }))
}

variable "users" {
  description = "Map of users to create in the identity store"
  type = map(object({

    name = object({
      family_name = string
      given_name  = string
    })
    emails = optional(list(string), [])
  }))
}

variable "memberships" {
  description = "Map of user-group memberships"
  type        = map(list(string)) # 各ユーザーをキーに、所属するグループのリストを値として持つ
}
