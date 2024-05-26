variable "user_name" {
  description = "IAMユーザー名"
  type        = string
  default     = ""
}

variable "path" {
  description = "IAMユーザーのパス"
  type        = string
  default     = "/"
}

variable "force_destroy" {
  description = "強制削除の許可でTerraformで管理されていない設定を持っていても削除"
  type        = bool
  default     = true
}