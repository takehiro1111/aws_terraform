/**
 * Common
 */
variable "cluster_name" {
  description = "ECSクラスター名"
  type        = string
}

variable "service_name" {
  description = "ECSサービス名"
  type        = string
}

/**
 * ECS metric_check
 */
variable "use_ecs_threshold_watch" {
  description = "ECSの監視可否"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "閾値を超過した際に通知するSNSトピック"
  type        = string
  default     = null
}

variable "ecs_threshold_watch" {
  description = "ECSの監視パラメータ"
  type = object({
    cpu = object({
      comparison_operator = string
      datapoints_to_alarm = string
      evaluation_periods  = number
      period              = number
      statistic           = string
      threshold           = number
      unit                = string
    })
    memory = object({
      comparison_operator = string
      datapoints_to_alarm = string
      evaluation_periods  = number
      period              = number
      statistic           = string
      threshold           = number
      unit                = string
    })
  })
  default = {
    cpu = {
      comparison_operator = "GreaterThanThreshold"
      datapoints_to_alarm = 3
      evaluation_periods  = 3
      period              = 60
      statistic           = "Maximum"
      threshold           = 60
      unit                = "Percent"
    }
    memory = {
      comparison_operator = "GreaterThanThreshold"
      datapoints_to_alarm = 3
      evaluation_periods  = 3
      period              = 60
      statistic           = "Maximum"
      threshold           = 60
      unit                = "Percent"
    }
  }
}

/**
 * ECS metric_alerm
 */
variable "use_cpu_alerm" {
  type    = bool
  default = false
}

variable "use_memory_alerm" {
  type    = bool
  default = false
}

variable "cpu_alerm" {
  description = "ECSの監視パラメータ"
  type = object({
    high = object({
      datapoints_to_alarm = string
      evaluation_periods  = number
      period              = number
      statistic           = string
      threshold           = number
      unit                = string
      alarm_actions       = list(string)
    })
    low = object({
      datapoints_to_alarm = string
      evaluation_periods  = number
      period              = number
      statistic           = string
      threshold           = number
      unit                = string
      alarm_actions       = list(string)
    })
  })
  default = {
    high = {
      datapoints_to_alarm = 1
      evaluation_periods  = 1
      period              = 60
      statistic           = "Average"
      threshold           = 60
      unit                = "Percent"
      alarm_actions       = null
    }
    low = {
      datapoints_to_alarm = 3
      evaluation_periods  = 3
      period              = 300
      statistic           = "Average"
      threshold           = 60
      unit                = "Percent"
      alarm_actions       = null
    }
  }
}

variable "memory_alerm" {
  description = "ECSの監視パラメータ"
  type = object({
    high = object({
      datapoints_to_alarm = string
      evaluation_periods  = number
      period              = number
      statistic           = string
      threshold           = number
      unit                = string
      alarm_actions       = list(string)
    })
    low = object({
      datapoints_to_alarm = string
      evaluation_periods  = number
      period              = number
      statistic           = string
      threshold           = number
      unit                = string
      alarm_actions       = list(string)
    })
  })
  default = {
    high = {
      datapoints_to_alarm = 1
      evaluation_periods  = 1
      period              = 60
      statistic           = "Average"
      threshold           = 60
      unit                = "Percent"
      alarm_actions       = null
    }
    low = {
      datapoints_to_alarm = 3
      evaluation_periods  = 3
      period              = 300
      statistic           = "Average"
      threshold           = 60
      unit                = "Percent"
      alarm_actions       = null
    }
  }
}
