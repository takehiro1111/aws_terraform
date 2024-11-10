#####################################################################################
# Web Server
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

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets = data.terraform_remote_state.development_network.outputs.private_subnets_id_development
    security_groups = [data.terraform_remote_state.development_security.outputs.sg_id_ecs]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.development_network.outputs.target_group_arn_web // TGがALBのリスナールールに設定されていないとエラーになるので注意。
    container_name   = "nginx-container"                                          // ALBに紐づけるコンテナの名前(コンテナ定義のnameと一致させる必要がある)
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

// タスク定義
resource "aws_ecs_task_definition" "web_nginx" {
  family                   = "nginx-task-define"
  cpu                      = 1024
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  network_mode       = "awsvpc"
  task_role_arn      = data.terraform_remote_state.development_security.outputs.iam_role_arn_ecs_task_role_web
  execution_role_arn = data.terraform_remote_state.development_security.outputs.iam_role_arn_ecs_task_execute_role_web

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
          awslogs-region        = "ap-northeast-1"
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
