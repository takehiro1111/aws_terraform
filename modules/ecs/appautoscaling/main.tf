#############################################################################
# Application AutoScaling
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

/**
 * ECS AutoScaling policy (scale_out_cpu)
 */
resource "aws_appautoscaling_policy" "this_scale_out_cpu" {
  count = var.create_auto_scaling_target && var.use_step_scaling ? 1 : 0

  name               = "Scale_out_cpu"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace

  step_scaling_policy_configuration {
    adjustment_type          = var.step_scaling.scale_out_cpu.adjustment_type
    cooldown                 = var.step_scaling.scale_out_cpu.cooldown
    metric_aggregation_type  = var.step_scaling.scale_out_cpu.metric_aggregation_type
    min_adjustment_magnitude = var.step_scaling.scale_out_cpu.min_adjustment_magnitude

    step_adjustment {
      metric_interval_lower_bound = var.step_scaling.scale_out_cpu.step_adjustment.metric_interval_lower_bound
      scaling_adjustment          = var.step_scaling.scale_out_cpu.step_adjustment.scaling_adjustment
    }
  }
}

/**
 * ECS AutoScaling policy (scale_in_cpu)
 */
resource "aws_appautoscaling_policy" "this_scale_in_cpu" {
  count = var.create_auto_scaling_target && var.use_step_scaling ? 1 : 0

  name               = "Scale_in_cpu"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace

  step_scaling_policy_configuration {
    adjustment_type          = var.step_scaling.scale_in_cpu.adjustment_type
    cooldown                 = var.step_scaling.scale_in_cpu.cooldown
    metric_aggregation_type  = var.step_scaling.scale_in_cpu.metric_aggregation_type
    min_adjustment_magnitude = var.step_scaling.scale_in_cpu.min_adjustment_magnitude

    step_adjustment {
      metric_interval_upper_bound = var.step_scaling.scale_in_cpu.step_adjustment.metric_interval_upper_bound
      scaling_adjustment          = var.step_scaling.scale_in_cpu.step_adjustment.scaling_adjustment
    }
  }
}

/**
 * ECS AutoScaling policy (scale_out_memory)
 */
resource "aws_appautoscaling_policy" "this_scale_out_memory" {
  count = var.create_auto_scaling_target && var.use_step_scaling ? 1 : 0

  name               = "Scale_out_memory"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace

  step_scaling_policy_configuration {
    adjustment_type          = var.step_scaling.scale_out_memory.adjustment_type
    cooldown                 = var.step_scaling.scale_out_memory.cooldown
    metric_aggregation_type  = var.step_scaling.scale_out_memory.metric_aggregation_type
    min_adjustment_magnitude = var.step_scaling.scale_out_memory.min_adjustment_magnitude

    step_adjustment {
      metric_interval_lower_bound = var.step_scaling.scale_out_memory.step_adjustment.metric_interval_lower_bound
      scaling_adjustment          = var.step_scaling.scale_out_memory.step_adjustment.scaling_adjustment
    }
  }
}

/**
 * ECS AutoScaling policy (scale_in_memory)
 */
resource "aws_appautoscaling_policy" "this_scale_in_memory" {
  count = var.create_auto_scaling_target && var.use_step_scaling ? 1 : 0

  name               = "Scale_in_memory"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace

  step_scaling_policy_configuration {
    adjustment_type          = var.step_scaling.scale_in_memory.adjustment_type
    cooldown                 = var.step_scaling.scale_in_memory.cooldown
    metric_aggregation_type  = var.step_scaling.scale_in_memory.metric_aggregation_type
    min_adjustment_magnitude = var.step_scaling.scale_in_memory.min_adjustment_magnitude

    step_adjustment {
      metric_interval_upper_bound = var.step_scaling.scale_in_memory.step_adjustment.metric_interval_upper_bound
      scaling_adjustment          = var.step_scaling.scale_in_memory.step_adjustment.scaling_adjustment
    }
  }
}

/**
 * ECS AutoScaling Target Tracking Scaling (CPU)
 */
resource "aws_appautoscaling_policy" "this_target_tracking_scale_cpu" {
  count = var.create_auto_scaling_target && var.use_target_tracking ? 1 : 0

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
    target_value = var.target_tracking.target_tracking_scaling_policy_configuration.cpu.target_value
    // スケールインの間隔はmm秒空ける
    scale_in_cooldown = var.target_tracking.target_tracking_scaling_policy_configuration.cpu.scale_in_cooldown
    // スケールアウトの間隔はmm秒空ける
    scale_out_cooldown = var.target_tracking.target_tracking_scaling_policy_configuration.cpu.scale_out_cooldown
  }

  depends_on = [aws_appautoscaling_target.this]
}

/**
 * ECS AutoScaling Target Tracking Scaling (memory)
 */
resource "aws_appautoscaling_policy" "this_target_tracking_scale_memory" {
  count = var.create_auto_scaling_target && var.use_target_tracking ? 1 : 0

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
    target_value = var.target_tracking.target_tracking_scaling_policy_configuration.memory.target_value
    // スケールインの間隔はmm秒空ける
    scale_in_cooldown = var.target_tracking.target_tracking_scaling_policy_configuration.memory.scale_in_cooldown
    // スケールアウトの間隔はmm秒空ける
    scale_out_cooldown = var.target_tracking.target_tracking_scaling_policy_configuration.memory.scale_out_cooldown
  }

  depends_on = [aws_appautoscaling_target.this]
}
