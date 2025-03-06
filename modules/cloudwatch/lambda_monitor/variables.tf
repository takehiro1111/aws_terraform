variable "param" {
  type = map(any)
}

variable "sns_arn" {
  type    = string
  default = null
}

variable "destination" {
  type = string
}

variable "role_arn" {
  type    = string
  default = null
}
