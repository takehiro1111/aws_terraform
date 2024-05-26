variable "name" {}

variable "image_name" {}

variable "cluster_id" {}

variable "target_group_arns" {}

variable "subnet_ids" {}

variable "security_group_ids" {}

variable "service_discovery_dns" {}

variable "dns_name" {}

variable "task_iam" {}

variable "cpu" {}

variable "memory" {}

variable "env" {}

variable "awslogs-group" {}

variable "heap_max" {
  default = 0
}

variable "heap_min" {
  default = 0
}

variable "tag" {
  description = "イメージのタグ"
  default     = "1.0.0"
}

variable "port" {
  description = "port"
  default     = 9000
}

variable "engine" {
  description = "実行環境"
  default     = "jvm"
}

variable "region" {
  description = "実行リージョン"
  default     = "ap-northeast-1"
}

variable "timezone" {
  description = "タイムゾーン"
  default     = "Asia/Tokyo"
}

variable "health_check_grace_period_seconds" {
  default = 0
}

variable "account_id" {
  description = "ECRを置くアカウントID"
  default     = data.aws_caller_identity.current.account_id
}
