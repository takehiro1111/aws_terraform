# Maintenance Mode -----------------------------------------
variable "full_maintenance" {
  description = "trueにすると全てのリクエストにメンテナンス画面を返す"
  type        = bool
  default     = false
}

variable "half_maintenance" {
  description = "trueにすると特定のIPを除いたリクエストにメンテナンス画面を返す"
  type        = bool
  default     = false
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}
