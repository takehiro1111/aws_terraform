/**
 * ECS AutoScaling policy
 */
variable "create_auto_scaling_target" {
  type    = bool
  default = false
}

variable "service_name" {
  description = "ECSサービス名"
  type        = string
}

variable "cluster_name" {
  description = "ECSクラスター名"
  type        = string
}

variable "max_capacity" {
  description = "AutoScallingの最大値"
  type        = number
}

variable "min_capacity" {
  description = "AutoScallingの最低値"
  type        = number
}

/**
 * ECS AutoScaling Scheduled Action
 */
variable "use_scheduled_action" {
  description = "スケジュールされたAutoScallingの適用"
  type        = bool
  default     = false
}

# 各スケジュールをセットで設定する必要があり、作成する際に漏れがないように型指定を行っている。
variable "schedule_app_auto_scale" {
  description = "スケジュールされたAutoScallingの指定"
  type = object({
    scale_out = object({
      schedule     = string
      max_capacity = number
      min_capacity = number
    })
    scale_in = object({
      schedule     = string
      max_capacity = number
      min_capacity = number
    })
  })
  default = null
}


