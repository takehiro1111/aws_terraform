#############################################################################
# AutoScaling
#############################################################################
/**
 * ECS AutoScaling target
 */
resource "aws_appautoscaling_target" "this" {
  count              = var.create_auto_scaling_target ? 1 : 0
  max_capacity       = var.max_capacity // スケールするタスクの最大数
  min_capacity       = var.min_capacity // スケールするタスクの最小数
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  lifecycle {
    ignore_changes = [max_capacity, min_capacity]
  }
}

/**
 * ECS AutoScaling Scheduled Action
 */
resource "aws_appautoscaling_scheduled_action" "scale_out" {
  count = var.create_auto_scaling_target && var.use_scheduled_action ? 1 : 0

  name               = "scheduled_scale_out"
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  schedule           = var.schedule_app_auto_scale.scale_out.schedule
  timezone           = "Asia/Tokyo"

  scalable_target_action {
    max_capacity = var.schedule_app_auto_scale.scale_out.max_capacity
    min_capacity = var.schedule_app_auto_scale.scale_out.min_capacity
  }
}

resource "aws_appautoscaling_scheduled_action" "scale_in" {
  count = var.create_auto_scaling_target && var.use_scheduled_action ? 1 : 0

  name               = "scheduled_scale_in"
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  schedule           = var.schedule_app_auto_scale.scale_in.schedule
  timezone           = "Asia/Tokyo"

  scalable_target_action {
    max_capacity = var.schedule_app_auto_scale.scale_in.max_capacity
    min_capacity = var.schedule_app_auto_scale.scale_in.min_capacity
  }
}

resource "aws_appautoscaling_scheduled_action" "reset" {
  count = var.create_auto_scaling_target && var.use_scheduled_action ? 1 : 0

  name               = "scheduled_reset"
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  schedule           = var.schedule_app_auto_scale.reset.schedule
  timezone           = "Asia/Tokyo"

  scalable_target_action {
    max_capacity = var.schedule_app_auto_scale.reset.max_capacity
    min_capacity = var.schedule_app_auto_scale.reset.min_capacity
  }
}

/**
 * ECS AutoScaling target
 */
resource "aws_appautoscaling_target" "this" {
  count = var.create_auto_scaling ? 1 : 0

  max_capacity       = var.max_capacity // スケールするタスクの最大数
  min_capacity       = var.min_capacity // スケールするタスクの最小数
  resource_id        = "service/${var.cluster_name}/${var.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  lifecycle {
    ignore_changes = [max_capacity, min_capacity]
  }
}

/**
 * ECS AutoScaling Scheduled Action
 */
resource "aws_appautoscaling_scheduled_action" "scale_out" {
  count = var.create_auto_scaling && var.use_scheduled_action ? 1 : 0

  name               = "scheduled_scale_out"
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  schedule           = var.schedule_app_auto_scale.scale_out.schedule
  timezone           = "Asia/Tokyo"

  scalable_target_action {
    max_capacity = var.schedule_app_auto_scale.scale_out.max_capacity
    min_capacity = var.schedule_app_auto_scale.scale_out.min_capacity
  }
}

resource "aws_appautoscaling_scheduled_action" "scale_in" {
  count = var.create_auto_scaling && var.use_scheduled_action ? 1 : 0

  name               = "scheduled_scale_in"
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  schedule           = var.schedule_app_auto_scale.scale_in.schedule
  timezone           = "Asia/Tokyo"

  scalable_target_action {
    max_capacity = var.schedule_app_auto_scale.scale_in.max_capacity
    min_capacity = var.schedule_app_auto_scale.scale_in.min_capacity
  }
}

/**
 * ECS AutoScaling policy (scale_out_cpu)
 */
resource "aws_appautoscaling_policy" "this_scale_out_cpu" {
  count = var.use_cpu ? 1 : 0

  name               = "Scale_out_cpu"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace

  step_scaling_policy_configuration {
    adjustment_type          = var.adjustment_type
    cooldown                 = var.cooldown
    metric_aggregation_type  = var.metric_aggregation_type
    min_adjustment_magnitude = var.min_adjustment_magnitude

    step_adjustment {
      metric_interval_lower_bound = var.metric_interval_lower_bound_cpu
      scaling_adjustment          = var.scaling_adjustment_scale_out_cpu
    }
  }
}

/**
 * ECS AutoScaling policy (scale_in_cpu)
 */
resource "aws_appautoscaling_policy" "this_scale_in_cpu" {
  count = var.use_cpu ? 1 : 0

  name               = "Scale_in_cpu"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace

  step_scaling_policy_configuration {
    adjustment_type          = var.adjustment_type
    cooldown                 = var.cooldown
    metric_aggregation_type  = var.metric_aggregation_type
    min_adjustment_magnitude = var.min_adjustment_magnitude

    step_adjustment {
      metric_interval_upper_bound = var.metric_interval_upper_bound_cpu
      scaling_adjustment          = var.scaling_adjustment_scale_in_cpu
    }
  }
}

/**
 * ECS AutoScaling policy (scale_out_memory)
 */
resource "aws_appautoscaling_policy" "this_scale_out_memory" {
  count = var.use_memory ? 1 : 0

  name               = "Scale_out_memory"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace

  step_scaling_policy_configuration {
    adjustment_type          = var.adjustment_type
    cooldown                 = var.cooldown
    metric_aggregation_type  = var.metric_aggregation_type
    min_adjustment_magnitude = var.min_adjustment_magnitude

    step_adjustment {
      metric_interval_lower_bound = var.metric_interval_lower_bound_memory
      scaling_adjustment          = var.scaling_adjustment_scale_out_memory
    }
  }
}

/**
 * ECS AutoScaling policy (scale_in_memory)
 */
resource "aws_appautoscaling_policy" "this_scale_in_memory" {
  count = var.use_memory ? 1 : 0

  name               = "Scale_in_memory"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace

  step_scaling_policy_configuration {
    adjustment_type          = var.adjustment_type
    cooldown                 = var.cooldown
    metric_aggregation_type  = var.metric_aggregation_type
    min_adjustment_magnitude = var.min_adjustment_magnitude

    step_adjustment {
      metric_interval_upper_bound = var.metric_interval_upper_bound_memory
      scaling_adjustment          = var.scaling_adjustment_scale_in_memory
    }
  }
}

/**
 * ECS AutoScaling Target Tracking Scaling (CPU)
 */
resource "aws_appautoscaling_policy" "this_target_tracking_scale_cpu" {
  count = var.use_target_tracking_cpu ? 1 : 0

  name               = "target-tracking-scale-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    // CPUの平均使用率がxx%になるように維持する
    target_value = var.cpu_target_value
    // スケールインの間隔はmm秒空ける
    scale_in_cooldown = var.cpu_scale_in_cooldown
    // スケールアウトの間隔はmm秒空ける
    scale_out_cooldown = var.cpu_scale_out_cooldown
  }

  depends_on = [aws_appautoscaling_target.this]
}

/**
 * ECS AutoScaling Target Tracking Scaling (memory)
 */
resource "aws_appautoscaling_policy" "this_target_tracking_scale_memory" {
  count = var.use_target_tracking_memory ? 1 : 0

  name               = "target-tracking-scale-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    // メモリの平均使用率がxx%になるように維持する
    target_value = var.memory_target_value
    // スケールインの間隔はmm秒空ける
    scale_in_cooldown = var.memory_scale_in_cooldown
    // スケールアウトの間隔はmm秒空ける
    scale_out_cooldown = var.memory_scale_out_cooldown
  }

  depends_on = [aws_appautoscaling_target.this]
}


/*
 * ECS AutoScaling cpu_high_alert (scale_out_cpu)
 */
resource "aws_cloudwatch_metric_alarm" "this_cpu_high" {
  count = var.use_cpu ? 1 : 0

  alarm_name          = "${var.name}_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = var.scale_out_datapoints_to_alarm
  evaluation_periods  = var.scale_out_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.scale_out_period
  statistic           = var.statistic
  threshold           = var.threshold_cpu_high
  unit                = var.unit

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.this.name
  }

  alarm_actions = [
    aws_appautoscaling_policy.this_scale_out_cpu[count.index].arn
  ]
}

/*
 * ECS AutoScaling cpu_low_alert (scale_in_cpu)
 */
resource "aws_cloudwatch_metric_alarm" "this_cpu_low" {
  count = var.use_cpu ? 1 : 0

  alarm_name          = "${var.name}_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  datapoints_to_alarm = var.scale_in_datapoints_to_alarm
  evaluation_periods  = var.scale_in_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.scale_in_period
  statistic           = var.statistic
  threshold           = var.threshold_cpu_low
  unit                = var.unit

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.this.name
  }

  alarm_actions = [
    aws_appautoscaling_policy.this_scale_in_cpu[count.index].arn
  ]
}

/*
 * ECS AutoScaling memory_high_alert (scale_in_memory)
 */
resource "aws_cloudwatch_metric_alarm" "this_memory_high" {
  count = var.use_memory ? 1 : 0

  alarm_name          = "${var.name}_memory_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = var.scale_out_datapoints_to_alarm
  evaluation_periods  = var.scale_out_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.scale_out_period
  statistic           = var.statistic
  threshold           = var.threshold_memory_high
  unit                = var.unit

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.this.name
  }

  alarm_actions = [
    aws_appautoscaling_policy.this_scale_out_memory[count.index].arn
  ]
}

/*
 * ECS AutoScaling cpu_low_alert (scale_in_memory)
 */
resource "aws_cloudwatch_metric_alarm" "this_memory_low" {
  count = var.use_memory ? 1 : 0

  alarm_name          = "${var.name}_memory_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  datapoints_to_alarm = var.scale_in_datapoints_to_alarm
  evaluation_periods  = var.scale_in_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.scale_in_period
  statistic           = var.statistic
  threshold           = var.threshold_memory_low
  unit                = var.unit

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.this.name
  }

  alarm_actions = [
    aws_appautoscaling_policy.this_scale_in_memory[count.index].arn
  ]
}

# ECSのCPU監視
resource "aws_cloudwatch_metric_alarm" "this_cpu_watch" {
  count = var.use_cpu_alerm ? 1 : 0

  alarm_name          = "${var.name}-cpu-watch"
  comparison_operator = var.cpu_comparison_operator
  datapoints_to_alarm = var.cpu_datapoints_to_alarm
  evaluation_periods  = var.cpu_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cpu_period
  statistic           = var.cpu_statistic
  threshold           = var.cpu_threshold
  unit                = var.cpu_unit

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.this.name
  }

  alarm_actions = [var.topic_arn]
  ok_actions    = [var.topic_arn]
}

# ECSのメモリ監視
resource "aws_cloudwatch_metric_alarm" "this_memory_watch" {
  count = var.use_memory_alerm ? 1 : 0

  alarm_name          = "${var.name}-memory-watch"
  comparison_operator = var.memory_comparison_operator
  datapoints_to_alarm = var.memory_datapoints_to_alarm
  evaluation_periods  = var.memory_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.memory_period
  statistic           = var.memory_statistic
  threshold           = var.memory_threshold
  unit                = var.memory_unit

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.this.name
  }

  alarm_actions = [var.topic_arn]
  ok_actions    = [var.topic_arn]
}
