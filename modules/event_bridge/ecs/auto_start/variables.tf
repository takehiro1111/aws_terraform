variable "state" {
  description = "イベントを有効化するかどうかを指定"
  default     = "DISABLED"
}

variable "schedule_expression" {
  description = "実行時間を指定"
  default     = null
}

variable "ecs_cluster_name" {
  description = "ECSのクラスター名を指定"
  default     = null
}

variable "ecs_service_list" {
  description = "ECSのサービス名を指定"
  default     = null
}

variable "name" {
  description = "イベントルール名を指定"
  default     = null
}
