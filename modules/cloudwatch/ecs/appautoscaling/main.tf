###################################################################################
# CloudWatch Alarm
###################################################################################
/* 
 * Monitor the ECS CPU and notify via SNS if it exceeds a threshold.
 */
resource "aws_cloudwatch_metric_alarm" "this_cpu_watch" {
  count = var.use_cpu_alerm && var.use_ecs_threshold_watch ? 1 : 0

  alarm_name          = "${var.service_name}-cpu-watch"
  comparison_operator = var.ecs_threshold_watch.cpu.comparison_operator
  datapoints_to_alarm = var.ecs_threshold_watch.cpu.datapoints_to_alarm
  evaluation_periods  = var.ecs_threshold_watch.cpu.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.ecs_threshold_watch.cpu.period
  statistic           = var.ecs_threshold_watch.cpu.statistic
  threshold           = var.ecs_threshold_watch.cpu.threshold
  unit                = var.ecs_threshold_watch.cpu.unit

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}

/* 
 * Monitor the ECS Memory and notify via SNS if it exceeds a threshold.
 */
resource "aws_cloudwatch_metric_alarm" "this_memory_watch" {
  count = var.use_memory_alerm && var.use_ecs_threshold_watch ? 1 : 0

  alarm_name          = "${var.service_name}-memory-watch"
  comparison_operator = var.ecs_threshold_watch.memory.comparison_operator
  datapoints_to_alarm = var.ecs_threshold_watch.memory.datapoints_to_alarm
  evaluation_periods  = var.ecs_threshold_watch.memory.evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.ecs_threshold_watch.memory.period
  statistic           = var.ecs_threshold_watch.memory.statistic
  threshold           = var.ecs_threshold_watch.memory.threshold
  unit                = var.ecs_threshold_watch.memory.unit

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}


/*
 * ECS AutoScaling cpu_high_alert (scale_out_cpu)
 */
resource "aws_cloudwatch_metric_alarm" "this_cpu_high" {
  count = var.use_cpu_alerm ? 1 : 0

  alarm_name          = "${var.service_name}_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = var.cpu_alerm.high.datapoints_to_alarm
  evaluation_periods  = var.cpu_alerm.high.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cpu_alerm.high.period
  statistic           = var.cpu_alerm.high.statistic
  threshold           = var.cpu_alerm.high.threshold
  unit                = var.cpu_alerm.high.unit

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = var.cpu_alerm.high.alarm_actions
}

# /*
#  * ECS AutoScaling cpu_low_alert (scale_in_cpu)
#  */
resource "aws_cloudwatch_metric_alarm" "this_cpu_low" {
  count = var.use_cpu_alerm ? 1 : 0

  alarm_name          = "${var.service_name}_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  datapoints_to_alarm = var.cpu_alerm.low.datapoints_to_alarm
  evaluation_periods  = var.cpu_alerm.low.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cpu_alerm.low.period
  statistic           = var.cpu_alerm.low.statistic
  threshold           = var.cpu_alerm.low.threshold
  unit                = var.cpu_alerm.low.unit

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = var.cpu_alerm.low.alarm_actions
}

# /*
#  * ECS AutoScaling memory_high_alert (scale_out_memory)
#  */
resource "aws_cloudwatch_metric_alarm" "this_memory_high" {
  count = var.use_memory_alerm ? 1 : 0

  alarm_name          = "${var.service_name}_memory_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = var.memory_alerm.high.datapoints_to_alarm
  evaluation_periods  = var.memory_alerm.high.evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.memory_alerm.high.period
  statistic           = var.memory_alerm.high.statistic
  threshold           = var.memory_alerm.high.threshold
  unit                = var.memory_alerm.high.unit

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = var.memory_alerm.high.alarm_actions
}

# /*
#  * ECS AutoScaling cpu_low_alert (scale_in_memory)
#  */
resource "aws_cloudwatch_metric_alarm" "this_memory_low" {
  count = var.use_memory_alerm ? 1 : 0

  alarm_name          = "${var.service_name}_memory_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  datapoints_to_alarm = var.memory_alerm.low.datapoints_to_alarm
  evaluation_periods  = var.memory_alerm.low.evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.memory_alerm.low.period
  statistic           = var.memory_alerm.low.statistic
  threshold           = var.memory_alerm.low.threshold
  unit                = var.memory_alerm.low.unit

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = var.memory_alerm.low.alarm_actions
}
