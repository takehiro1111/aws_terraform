####################################################
# SSM Doocument
####################################################
module "auto_stop_start_ecs" {
  source = "../../modules/ssm/ecs"
}

####################################################
# EventBridge
####################################################
// 年始の第一営業日に一斉に起動するための一時的な設定。(2024/12/23)
module "autoEcsStart_new_year_first_working_day" {
  source = "../../modules/event_bridge/ecs/auto_start"

  ecs_service_list = [
    aws_ecs_service.web_nginx.name,
    aws_ecs_service.locust.name,
  ]
  state               = "ENABLED"
  ecs_cluster_name    = aws_ecs_cluster.web.name
  name                = "StartEcsStg-new-year-first-working-day"
  schedule_expression = "cron(43 10 23 12 ? 2024)" # JST: 2025年1月6日 8:00
}

module "autoEcsSop_new_year_first_working_day" {
  source = "../../modules/event_bridge/ecs/auto_stop"

  ecs_service_list = [
    aws_ecs_service.web_nginx.name,
    aws_ecs_service.locust.name,
  ]
  state               = "ENABLED"
  ecs_cluster_name    = aws_ecs_cluster.web.name
  name                = "SopEcsStg-new-year-first-working-day"
  schedule_expression = "cron(49 10 23 12 ? 2024)" # JST: 2025年1月6日 8:00
}

####################################################
# IAM
####################################################
/* 
 * ECS AutoStop Start
 */
resource "aws_iam_role" "ecs_auto_contorol" {
  name = "ecs-auto-control"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "ecs_auto_contorol" {
  statement {
    effect = "Allow"
    actions = [
      "*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_auto_contorol" {
  name   = aws_iam_role.ecs_auto_contorol.name
  role   = aws_iam_role.ecs_auto_contorol.name
  policy = data.aws_iam_policy_document.ecs_auto_contorol.json
}


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
  health_check_grace_period_seconds = 0
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

  service_registries {
    registry_arn = aws_service_discovery_service.web.arn
  }
}

resource "aws_ecs_service" "locust" {
  name                              = "locust"
  cluster                           = aws_ecs_cluster.web.arn
  task_definition                   = "locust-task-define"
  desired_count                     = 0
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0" # LATESTの挙動
  health_check_grace_period_seconds = 0
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
    target_group_arn = data.terraform_remote_state.development_network.outputs.target_group_arn_locust // TGがALBのリスナールールに設定されていないとエラーになるので注意。
    container_name   = "locust-container"                                                              // ALBに紐づけるコンテナの名前(コンテナ定義のnameと一致させる必要がある)
    container_port   = 8089                                                                            // locustのデフォルトでDockerfileで定義している。
  }

  service_registries {
    registry_arn = aws_service_discovery_service.web.arn
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [aws_ecs_task_definition.locust]
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
      image     = "${data.aws_caller_identity.self.account_id}.dkr.ecr.${data.aws_region.default.name}.amazonaws.com/locust:latest"
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

resource "aws_ecs_task_definition" "locust" {
  family                   = "locust-task-define"
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
      name      = "locust-container"
      image     = "${data.aws_caller_identity.self.account_id}.dkr.ecr.${data.aws_region.default.name}.amazonaws.com/locust:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 8089
          hostPort      = 8089
        },
        # {
        #   protocol      = "tcp"
        #   containerPort = 5557
        #   hostPort      = 5557
        # },
        # {
        #   protocol      = "tcp"
        #   containerPort = 5558
        #   hostPort      = 5558
        # },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-stream-prefix = "locust"
          awslogs-create-group  = "true"
          awslogs-group         = data.terraform_remote_state.development_management.outputs.cw_log_group_name_ecs_locust
          awslogs-region        = data.aws_region.default.name
        }
      }
    }
  ])

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

#######################################################################################
# Application AutoScaling
#######################################################################################
/* 
 * Schedule AutoScaling
 */
module "appautoscaling_web" {
  source = "../../modules/ecs/appautoscaling"

  create_auto_scaling_target = false
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

  use_target_tracking = false
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

  use_step_scaling = false
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
