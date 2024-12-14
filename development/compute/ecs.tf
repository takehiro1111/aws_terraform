#####################################################################################
# ECS
#####################################################################################
resource "aws_ecs_cluster" "web" {
  name = "cluster-web"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        s3_bucket_name = data.terraform_remote_state.development_storage.outputs.s3_bucket_id_logging_target
        s3_key_prefix  = "ecs_exec"
      }
    }
  }

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

// 名前空間
resource "aws_service_discovery_private_dns_namespace" "web" {
  name = "web.service_discovery_private_dns_namespace"
  vpc  = data.terraform_remote_state.development_network.outputs.vpc_id_development
}

// サービスディスカバリ
resource "aws_service_discovery_service" "web" {
  name          = aws_service_discovery_private_dns_namespace.web.name
  force_destroy = true
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.web.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

// ECSサービス
resource "aws_ecs_service" "web_nginx" {
  name                              = "nginx-service-stg"
  cluster                           = aws_ecs_cluster.web.arn
  task_definition                   = "nginx-task-define"
  desired_count                     = 0
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0" # LATESTの挙動
  health_check_grace_period_seconds = 60
  enable_execute_command            = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = data.terraform_remote_state.development_network.outputs.private_subnets_id_development
    security_groups  = [data.terraform_remote_state.development_security.outputs.sg_id_ecs]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.development_network.outputs.target_group_arn_web // TGがALBのリスナールールに設定されていないとエラーになるので注意。
    container_name   = "nginx-container"                                                            // ALBに紐づけるコンテナの名前(コンテナ定義のnameと一致させる必要がある)
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

// タスク定義
resource "aws_ecs_task_definition" "web_nginx" {
  family                   = "nginx-task-define"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  network_mode       = "awsvpc"
  task_role_arn      = data.terraform_remote_state.development_security.outputs.iam_role_arn_ecs_task_role_web
  execution_role_arn = data.terraform_remote_state.development_security.outputs.iam_role_arn_ecs_task_execute_role_web
  track_latest       = true

  container_definitions = jsonencode([
    {
      name      = "nginx-container"
      image     = "${data.aws_caller_identity.self.account_id}.dkr.ecr.${data.aws_region.default.name}.amazonaws.com/nginx:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-stream-prefix = "web"
          awslogs-create-group  = "true"
          awslogs-group         = data.terraform_remote_state.development_management.outputs.cw_log_group_name_ecs_nginx
          awslogs-region        = data.aws_region.default.name
          # Name = "nginx-blue-green-test"
          # Port = "24224"
          # Host = "127.0.0.1"
        }
      }
    },
    # {
    #   name      = "side-car-firelens"
    #   image     = "amazon/aws-for-fluent-bit:latest"
    #   essential = true
    #   firelensConfiguration = {
    #     type = "fluentbit"
    #   }
    #   cpu    = 256
    #   memory = 512
    #   logConfiguration = {
    #     logDriver = "awslogs"
    #     options = {
    #       awslogs-stream-prefix = "test1"
    #       awslogs-create-group  = "true"
    #       awslogs-group         = "ecs/fluent-bit/test"
    #       awslogs-region        = "ap-northeast-1"
    #     }
    #   }
    # },
  ])

  # lifecycle {
  #   ignore_changes = [container_definitions,task_definition]
  # }
}

#######################################################################################
# Application AutoScaling
#######################################################################################
/* 
 * Schedule AutoScaling
 */
module "appautoscaling_web" {
  source = "../../modules/ecs/appautoscaling"

  create_auto_scaling_target = true
  cluster_name               = aws_ecs_cluster.web.name
  service_name               = aws_ecs_service.web_nginx.name
  max_capacity               = 3
  min_capacity               = 1

  use_scheduled_action = false
  schedule_app_auto_scale = {
    scale_out = {
      schedule     = "cron(57 18 ? * MON-FRI *)"
      max_capacity = 3
      min_capacity = 2
    }
    scale_in = {
      schedule     = "cron(59 18 ? * MON-FRI *)"
      max_capacity = 3
      min_capacity = 1
    }
  }

  use_target_tracking = true
  target_tracking = {
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

  use_step_scaling = true
  step_scaling = {
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

#######################################################################################
# Cloudwatch Alarm
#######################################################################################
module "cw_alarm_for_ecs" {
  source = "../../modules/cloudwatch/ecs/appautoscaling"

  cluster_name = aws_ecs_cluster.web.name
  service_name = aws_ecs_service.web_nginx.name

  use_ecs_threshold_watch = true
  sns_topic_arn           = data.terraform_remote_state.development_management.outputs.sns_topic_arn_ecs_cw_alert
  ecs_threshold_watch = {
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

  use_cpu_alerm = true
  cpu_alerm = {
    high = {
      datapoints_to_alarm = 1
      evaluation_periods  = 1
      period              = 60
      statistic           = "Average"
      threshold           = 60
      unit                = "Percent"
      alarm_actions       = module.appautoscaling_web.app_autoscaling_policy_arn_scale_out_cpu
    }
    low = {
      datapoints_to_alarm = 3
      evaluation_periods  = 3
      period              = 300
      statistic           = "Average"
      threshold           = 60
      unit                = "Percent"
      alarm_actions       = module.appautoscaling_web.app_autoscaling_policy_arn_scale_in_cpu
    }
  }

  use_memory_alerm = true
  memory_alerm = {
    high = {
      datapoints_to_alarm = 1
      evaluation_periods  = 1
      period              = 60
      statistic           = "Average"
      threshold           = 60
      unit                = "Percent"
      alarm_actions       = module.appautoscaling_web.app_autoscaling_policy_arn_scale_out_memory
    }
    low = {
      datapoints_to_alarm = 3
      evaluation_periods  = 3
      period              = 300
      statistic           = "Average"
      threshold           = 60
      unit                = "Percent"
      alarm_actions       = module.appautoscaling_web.app_autoscaling_policy_arn_scale_in_memory
    }
  }
}
