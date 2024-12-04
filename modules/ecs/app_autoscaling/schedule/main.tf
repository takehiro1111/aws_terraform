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
