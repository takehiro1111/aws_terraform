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
    reset = object({
      schedule     = string
      max_capacity = number
      min_capacity = number
    })
  })
  default = null
}


/**
 * ECS AutoScaling policy
 */
variable "use_cpu" {
  type    = bool
  default = false
}

variable "use_memory" {
  type    = bool
  default = false
}

variable "adjustment_type" {
  description = ""
  default     = "ChangeInCapacity"
}

variable "cooldown" {
  description = ""
  default     = 300 // 300秒=5分
}

variable "metric_aggregation_type" {
  description = ""
  default     = "Average"
}

variable "min_adjustment_magnitude" {
  description = ""
  default     = 0
}

variable "metric_interval_lower_bound_cpu" {
  description = ""
  default     = 0
}

variable "metric_interval_upper_bound_cpu" {
  description = ""
  default     = 0
}

variable "metric_interval_lower_bound_memory" {
  description = ""
  default     = 0
}

variable "metric_interval_upper_bound_memory" {
  description = ""
  default     = 0
}

variable "scaling_adjustment_scale_out_cpu" {
  description = ""
  default     = 1
}

variable "scaling_adjustment_scale_in_cpu" {
  description = ""
  default     = -1
}

variable "scaling_adjustment_scale_out_memory" {
  description = ""
  default     = 1
}

variable "scaling_adjustment_scale_in_memory" {
  description = ""
  default     = -1
}

/**
 * ECS AutoScaling policy (Target Tracking Scaling)
 */
variable "use_target_tracking_cpu" {
  type    = bool
  default = false
}

variable "use_target_tracking_memory" {
  type    = bool
  default = false
}

variable "cpu_target_value" {
  description = ""
  default     = 50
}

variable "cpu_scale_in_cooldown" {
  description = ""
  default     = 60
}

variable "cpu_scale_out_cooldown" {
  description = ""
  default     = 30
}

variable "memory_target_value" {
  description = ""
  default     = 50
}

variable "memory_scale_in_cooldown" {
  description = ""
  default     = 60
}

variable "memory_scale_out_cooldown" {
  description = ""
  default     = 30
}

/**
 * ECS AutoScaling metric_alerm
 */
variable "use_cpu_alerm" {
  type    = bool
  default = false
}

variable "use_memory_alerm" {
  type    = bool
  default = false
}

variable "scale_out_datapoints_to_alarm" {
  description = ""
  default     = 1
}

variable "scale_out_evaluation_periods" {
  description = ""
  default     = 1
}

variable "scale_in_datapoints_to_alarm" {
  description = ""
  default     = 3
}

variable "scale_in_evaluation_periods" {
  description = ""
  default     = 3
}

variable "scale_out_period" {
  description = ""
  default     = 60 // 300秒=5分
}

variable "scale_in_period" {
  description = ""
  default     = 300 // 300秒=5分
}

variable "statistic" {
  description = ""
  default     = "Average"
}

variable "threshold_cpu_high" {
  description = ""
  default     = null
}

variable "threshold_cpu_low" {
  description = ""
  default     = null
}

variable "threshold_memory_high" {
  description = ""
  default     = null
}

variable "threshold_memory_low" {
  description = ""
  default     = null
}

variable "unit" {
  description = ""
  default     = "Percent"
}

/**
 * ECS metric_check
 */
variable "cpu_comparison_operator" {
  description = ""
  type        = string
  default     = "GreaterThanThreshold"
}

variable "memory_comparison_operator" {
  description = ""
  type        = string
  default     = "GreaterThanThreshold"
}

variable "cpu_evaluation_periods" {
  description = ""
  type        = number
  default     = 3
}

variable "memory_evaluation_periods" {
  description = ""
  type        = number
  default     = 3
}

variable "cpu_datapoints_to_alarm" {
  description = ""
  type        = number
  default     = 3
}

variable "memory_datapoints_to_alarm" {
  description = ""
  type        = number
  default     = 3
}

variable "cpu_period" {
  description = ""
  type        = number
  default     = 60
}

variable "memory_period" {
  description = ""
  type        = number
  default     = 60
}

variable "cpu_statistic" {
  description = ""
  type        = string
  default     = "Maximum"
}

variable "memory_statistic" {
  description = ""
  type        = string
  default     = "Maximum"
}

variable "cpu_threshold" {
  description = ""
  type        = string
  default     = null
}

variable "memory_threshold" {
  description = ""
  type        = string
  default     = null
}

variable "cpu_unit" {
  description = ""
  type        = string
  default     = "Percent"
}

variable "memory_unit" {
  description = ""
  default     = "Percent"
}

variable "topic_arn" {
  description = ""
  type        = string
  default     = null
}
