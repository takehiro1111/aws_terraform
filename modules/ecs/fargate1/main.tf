/**
 * ## Description
 * サービスディスカバリを利用したFargate Spotコンテナを作成するモジュール
 * 基本的には、ステージング環境での利用を想定
 *
 * ## Usage:
 *
 * ```hcl
 * module "omotenashi_work_main_v2-sd" {
 *   source = "../../modules/ecs_fargate_spot"
 *
 *   name                  = "omotenashi-work-main-v2-with-sd"
 *   image_name            = "omotenashi-work-main-v2"
 *   cluster_id            = aws_ecs_cluster.omotenashi.id
 *   target_group_arns     = [aws_lb_target_group.work_main_v2.arn]
 *   subnet_ids            = [aws_subnet.sn_private_1.id]
 *   security_group_ids    = [aws_security_group.default.id]
 *   service_discovery_dns = aws_service_discovery_private_dns_namespace.omotenashi.id
 *   dns_name              = "main"
 *   task_iam              = module.ecs_task.iam_role_arn
 *   cpu                   = 1024
 *   memory                = 2048
 *   env                   = "prod"
 *   awslogs-group         = aws_cloudwatch_log_group.omotenashi-work-main.name
 *   tag                   = "2.0.50"
 * }
 * ```
 */


locals {
  jvm_command = <<EOT
  [
    "-J-Xms${var.heap_min != 0 ? var.heap_min : floor(var.memory * 0.3)}M",
    "-J-Xmx${var.heap_max != 0 ? var.heap_max : floor(var.memory * 0.7)}M",
    "-Dconfig.resource=env.${var.env}/application.conf",
    "-Dlogger.resource=env.${var.env}/logback.xml"
  ]
  EOT

  node_command = "[]"

  none_command = "[]"

  command = var.engine == "jvm" ? local.jvm_command : var.engine == "node" ? local.node_command : local.none_command
}

resource "aws_ecs_service" "this" {
  name             = var.name
  cluster          = var.cluster_id
  desired_count    = 0
  platform_version = "1.4.0"

  enable_execute_command             = true
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  tags                               = {}

  dynamic "load_balancer" {
    for_each = var.target_group_arns
    content {
      target_group_arn = load_balancer.value
      container_name   = var.name
      container_port   = 9000
    }
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  service_registries {
    container_port = 0
    port           = 0
    registry_arn   = aws_service_discovery_service.this.arn
  }

  task_definition = aws_ecs_task_definition.this.arn

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }


  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
    ]
  }
}

resource "aws_service_discovery_service" "this" {
  name = var.dns_name

  dns_config {
    namespace_id = var.service_discovery_dns

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

#tfsec:ignore:aws-ecs-no-plaintext-secrets
resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = var.task_iam
  execution_role_arn       = var.task_iam
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = <<DEFINITION
[
  {
    "networkMode": "awsvpc",
    "essential": true,
    "image": "${var.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.image_name}:${var.tag}",
    "memoryReservation": ${var.memory},
    "name": "${var.name}",
    "environment" : [
        {
          "name": "TZ",
          "value": "${var.timezone}"
        }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${var.awslogs-group}",
            "awslogs-region": "${var.region}",
            "awslogs-stream-prefix": "${var.name}"
        }
    },
    "portMappings": [
      {
        "containerPort": ${var.port},
        "hostPort": ${var.port}
      },
      {
        "containerPort": 9095,
        "hostPort": 9095
      }
    ],
    "command": ${local.command}
  }
]
DEFINITION

}
