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


/**
 * ECS AutoScaling policy(StepScaling)
 */
variable "use_step_scaling" {
  type    = bool
  default = false
}

variable "step_scaling" {
  description = "ステップスケーリングポリシー"
  type = object({
    scale_out_cpu = object({
      adjustment_type          = string
      cooldown                 = number
      metric_aggregation_type  = string
      min_adjustment_magnitude = number
      step_adjustment = object({
        metric_interval_lower_bound = number
        scaling_adjustment          = number
      })
    })
    scale_in_cpu = object({
      adjustment_type          = string
      cooldown                 = number
      metric_aggregation_type  = string
      min_adjustment_magnitude = number
      step_adjustment = object({
        metric_interval_upper_bound = number
        scaling_adjustment          = number
      })
    })
    scale_out_memory = object({
      adjustment_type          = string
      cooldown                 = number
      metric_aggregation_type  = string
      min_adjustment_magnitude = number
      step_adjustment = object({
        metric_interval_lower_bound = number
        scaling_adjustment          = number
      })
    })
    scale_in_memory = object({
      adjustment_type          = string
      cooldown                 = number
      metric_aggregation_type  = string
      min_adjustment_magnitude = number
      step_adjustment = object({
        metric_interval_upper_bound = number
        scaling_adjustment          = number
      })
    })
  })

  default = {
    scale_out_cpu = {
      adjustment_type          = "ChangeInCapacity"
      cooldown                 = 180
      metric_aggregation_type  = "Average"
      min_adjustment_magnitude = 0
      step_adjustment = {
        metric_interval_lower_bound = 0
        scaling_adjustment          = 1
      }
    }
    scale_in_cpu = {
      adjustment_type          = "ChangeInCapacity"
      cooldown                 = 180
      metric_aggregation_type  = "Average"
      min_adjustment_magnitude = 0
      step_adjustment = {
        metric_interval_upper_bound = 0
        scaling_adjustment          = -1
      }
    }
    scale_out_memory = {
      adjustment_type          = "ChangeInCapacity"
      cooldown                 = 180
      metric_aggregation_type  = "Average"
      min_adjustment_magnitude = 0
      step_adjustment = {
        metric_interval_lower_bound = 0
        scaling_adjustment          = 1
      }
    }
    scale_in_memory = {
      adjustment_type          = "ChangeInCapacity"
      cooldown                 = 180
      metric_aggregation_type  = "Average"
      min_adjustment_magnitude = 0
      step_adjustment = {
        metric_interval_upper_bound = 0
        scaling_adjustment          = -1
      }
    }
  }
}

/**
 * ECS AutoScaling policy(TargetTrackingScaling)
 */
variable "use_target_tracking" {
  type    = bool
  default = false
}

variable "target_tracking" {
  description = "ステップスケーリングポリシー"
  type = object({
    target_tracking_scaling_policy_configuration = object({
      cpu = object({
        target_value       = number
        scale_in_cooldown  = number
        scale_out_cooldown = number
      })
      memory = object({
        target_value       = number
        scale_in_cooldown  = number
        scale_out_cooldown = number
      })
    })
  })

  default = {
    target_tracking_scaling_policy_configuration = {
      cpu = {
        target_value       = 50
        scale_in_cooldown  = 60
        scale_out_cooldown = 30
      }
      memory = {
        target_value       = 50
        scale_in_cooldown  = 60
        scale_out_cooldown = 30
      }
    }
  }
}
