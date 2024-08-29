#####################################################
# EC2
#####################################################
// WEBサーバ用のインスタンス
resource "aws_instance" "common" {
  count = var.create_web_instance ? 1 : 0

  ami                         = "ami-027a31eff54f1fe4c" // 「Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type」のAMI
  subnet_id                   = aws_subnet.common["public_a"].id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.ecs_stg.id]
  associate_public_ip_address = false // SessionManagerでのログインに絞りたいためGIPの付与は行わない。
  iam_instance_profile        = aws_iam_instance_profile.session_manager.name

  // Apacheのインストールまで実施
  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd
                systemctl start httpd
                systemctl enable httpd
                EOF

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = false
    encrypted             = true

    tags = {
      Name = "web-root-volume-${count.index}"
    }
  }

  tags = {
    Name = "common-instance"
  }
}

/*
 * Prometheus,Grafana用 
 */
# module "prometheus_server" {
#   source = "../modules/ec2/general_instance"

#   env                  = local.env
#   vpc_id               = aws_vpc.common.id
#   subnet_id            = aws_subnet.common["public_a"].id // NAT GWはを出来る限り有効化したくないため。
#   iam_instance_profile = aws_iam_instance_profile.session_manager.name

#   root_volume_name = "prometheus-server"
#   inastance_name   = "prometheus-server"

#   ## SessionManagerの設定は既に作成済みのためfalse
#   create_common_resource = false

#   ## 一時的にルートボリューム以外のEBSを作成する場合はtrueにする
#   create_tmp_ebs_resource = false

#   sg_name = "security-bastion"
# }

/*
 * Node Exporter用 
 */
# module "node_exporter" {
#   source = "../modules/ec2/general_instance"

#   env                  = "stg"
#   vpc_id               = aws_vpc.common.id
#   subnet_id            = aws_subnet.common["public_a"].id // NAT GWはを出来る限り有効化したくないため。
#   iam_instance_profile = aws_iam_instance_profile.session_manager.name

#   root_volume_name = "node-exporter"
#   inastance_name   = "node-exporter"

#   ## SessionManagerの設定は既に作成済みのためfalse
#   create_common_resource = false

#   ## 一時的にルートボリューム以外のEBSを作成する場合はtrueにする
#   create_tmp_ebs_resource = false

#   sg_name = "prometheus-node-exporter"
# }

#####################################################
# ECS
#####################################################
// cluster
# resource "aws_ecs_cluster" "web" {
#   name = "cluster-web"
# }

# // 名前空間
# resource "aws_service_discovery_private_dns_namespace" "web" {
#   name = "web.internal"
#   vpc  = aws_vpc.common.id
# }

# // サービスディスカバリ
# resource "aws_service_discovery_service" "web" {
#   name = aws_service_discovery_private_dns_namespace.web.name
#   dns_config {
#     namespace_id = aws_service_discovery_private_dns_namespace.web.id

#     dns_records {
#       ttl  = 10
#       type = "A"
#     }

#     routing_policy = "MULTIVALUE"
#   }

#   health_check_custom_config {
#     failure_threshold = 1
#   }
# }

# // ECSサービス
# resource "aws_ecs_service" "nginx" {
#   name                              = "nginx-service-stg"
#   cluster                           = aws_ecs_cluster.web.arn
#   task_definition                   = "nginx-task-define"
#   desired_count                     = 1
#   launch_type                       = "FARGATE"
#   platform_version                  = "1.4.0"
#   health_check_grace_period_seconds = 60

#   deployment_circuit_breaker {
#     enable   = true
#     rollback = true
#   }

#   network_configuration {
#     subnets = [aws_subnet.common["private_c"].id]
#     security_groups = [
#       aws_security_group.ecs_stg.id,
#     ]
#     assign_public_ip = false
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.ecs_nginx.arn // TGがALBのリスナールールに設定されていないとエラーになるので注意。
#     container_name   = "ngix-container"                  // ALBに紐づけるコンテナの名前(コンテナ定義のnameと一致させる必要がある)
#     container_port   = 80
#   }

#   lifecycle {
#     ignore_changes = [task_definition]
#   }
# }

# // タスク定義
# resource "aws_ecs_task_definition" "nginx" {
#   family                   = "nginx-task-define"
#   cpu                      = 1024
#   memory                   = 2048
#   requires_compatibilities = ["FARGATE"]

#   runtime_platform {
#     operating_system_family = "LINUX"
#     cpu_architecture        = "X86_64"
#   }

#   network_mode       = "awsvpc"
#   task_role_arn      = module.ecs_task_stg.iam_role_arn
#   execution_role_arn = data.aws_iam_role.ecs_task_execute.arn

#   container_definitions = jsonencode([
#     {
#       name      = "ngix-container"
#       image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.default.name}.amazonaws.com/nginx:c69bbb31a7db79bad4dfd9c87e2e7070ddd1ad94"
#       cpu       = 256
#       memory    = 512
#       essential = true
#       portMappings = [
#         {
#           protocol      = "tcp"
#           containerPort = 80
#           hostPort      = 80
#         }
#       ]
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-stream-prefix = "web"
#           awslogs-create-group  = "true"
#           awslogs-group         = "ecs-service/blue-green-test"
#           awslogs-region        = "ap-northeast-1"
#           # Name = "nginx-blue-green-test"
#           # Port = "24224"
#           # Host = "127.0.0.1"
#         }
#       }
#     },
#     # {
#     #   name      = "side-car-firelens"
#     #   image     = "amazon/aws-for-fluent-bit:latest"
#     #   essential = true
#     #   firelensConfiguration = {
#     #     type = "fluentbit"
#     #   }
#     #   cpu    = 256
#     #   memory = 512
#     #   logConfiguration = {
#     #     logDriver = "awslogs"
#     #     options = {
#     #       awslogs-stream-prefix = "test1"
#     #       awslogs-create-group  = "true"
#     #       awslogs-group         = "ecs/fluent-bit/test"
#     #       awslogs-region        = "ap-northeast-1"
#     #     }
#     #   }
#     # },
#   ])

#   # lifecycle {
#   #   ignore_changes = [container_definitions]
#   # }
# }
