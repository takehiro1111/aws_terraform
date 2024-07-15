locals {
  servicename = "common"
  env         = "stg"
  repository  = "aws_terraform"
  directory   = "aws_terraform/common"

  accounnt_id = data.aws_caller_identity.current.id

  # CloudFront Origin ID
  ecs_origin_id = "ALB-ecs"

  # AuroraのCluster識別子
  idetifier_aurora_cluster = "aurora-cluster"

  # AMIを参照する際に使用
  aws_owner = "137112412989"

  # ECS
  main = "main-ecs"
  api  = "api-ecs"
}

# AuroraのSGのInboundRuleで許可するIP群
locals {
  private_sb_ips = [
    module.value.subnet_ip_common.a_private,
    module.value.subnet_ip_common.c_private,
    module.value.subnet_ip_common.d_private,
  ]
}

locals {
  private_sb_ips2 = [
    module.value.subnet_ip_common.a_public,
    module.value.subnet_ip_common.c_public,
    module.value.subnet_ip_common.d_public,
  ]
}

/* 
 * CloudFront
 */
// CloudFrontのカスタムエラーレスポンス
locals {
  custom_error_responses = [
    {
      error_caching_min_ttl = 10
      error_code            = 500
      response_code         = 500
      response_page_path    = "/maintenance/maintenance.html"
    },
    {
      error_caching_min_ttl = 10
      error_code            = 501
      response_code         = 501
      response_page_path    = "/maintenance/maintenance.html"
    },
    {
      error_caching_min_ttl = 10
      error_code            = 502
      response_code         = 502
      response_page_path    = "/maintenance/maintenance.html"
    },
    {
      error_caching_min_ttl = 10
      error_code            = 504
      response_code         = 504
      response_page_path    = "/maintenance/maintenance.html"
    }
  ]

  // メンテモードをtrueにする場合は503エラーのカスタムエラーレスポンスを作成する。
  conditional_custom_error_responses = var.full_maintenance || var.half_maintenance ? [
    {
      error_caching_min_ttl = 10
      error_code            = 503
      response_code         = 503
      response_page_path    = "/maintenance/maintenance.html"
    }
  ] : []
}

// CloudFrontのロギング用バケットのPrefix設定
locals {
  processing            = replace(module.value.cdn_tanaka_cloud_net, ".", "_")
  logging_config_prefix = replace(local.processing, "-", "_")
}

/* 
 * S3
 */
// ライフサイクルポリシーをdynamicブロックで再利用
locals {
  lifecycle_configuration = [
    {
      id     = local.logging_config_prefix
      status = "Enabled"
      prefix = local.logging_config_prefix

      transitions = [
        { days = 30, storage_class = "STANDARD_IA" },
        { days = 180, storage_class = "GLACIER" },
        { days = 365, storage_class = "DEEP_ARCHIVE" }
      ]

      noncurrent_version_transition = {
        newer_noncurrent_versions = 1
        noncurrent_days           = 30
        storage_class             = "DEEP_ARCHIVE"
      }
    }
  ]
}


/* 
 * VPC Flow Logs Parameter
 */
locals {
  flow_logs = {
    cloudwatch_logs = {
      create               = false
      iam_role_arn         = aws_iam_role.flow_log.arn
      log_destination_type = "cloud-watch-logs"
      log_destination      = aws_cloudwatch_log_group.flow_log.arn
      traffic_type         = "ACCEPT"
      // デフォルトのログフォーマット
      log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"

      max_aggregation_interval = 600
    }
    s3 = {
      create                   = false
      log_destination_type     = "s3"
      log_destination          = aws_s3_bucket.flow_log.arn
      traffic_type             = "ACCEPT"
      log_format               = "$${account-id} $${region} $${interface-id} $${srcaddr} $${dstaddr} $${pkt-srcaddr} $${pkt-dstaddr} $${protocol} $${action} $${log-status}"
      max_aggregation_interval = 60
    }
  }
}

/* 
 * Subnets Parameter
 */
locals {
  subnets = {
    public_a = {
      cidr_block = module.value.subnet_ip_common.a_public
      az         = module.value.az.ap_northeast_1.a
    }
    public_c = {
      cidr_block = module.value.subnet_ip_common.c_public
      az         = module.value.az.ap_northeast_1.c
    }
    private_a = {
      cidr_block = module.value.subnet_ip_common.a_private
      az         = module.value.az.ap_northeast_1.a
    }
    private_c = {
      cidr_block = module.value.subnet_ip_common.c_private
      az         = module.value.az.ap_northeast_1.c
    }
  }
}

/* 
 * Route Tables Parameter
 */
locals {
  rtb = ["public", "private"]

  route = {
    igw = {
      create                 = true
      route_table_id         = aws_route_table.common["public"].id
      destination_cidr_block = module.value.full_open_ip
      gateway_id             = aws_internet_gateway.common.id
    }
    nat = {
      create                 = false
      route_table_id         = aws_route_table.common["private"].id
      destination_cidr_block = module.value.full_open_ip
      nat_gateway_id         = aws_nat_gateway.common[*].id
    }
  }

  rtb_association = {
    public_a = {
      subnet_id      = aws_subnet.common["public_a"].id
      route_table_id = aws_route_table.common["public"].id
    }
    public_c = {
      subnet_id      = aws_subnet.common["public_c"].id
      route_table_id = aws_route_table.common["public"].id
    }
    private_a = {
      subnet_id      = aws_subnet.common["private_a"].id
      route_table_id = aws_route_table.common["private"].id
    }
    private_a = {
      subnet_id      = aws_subnet.common["private_c"].id
      route_table_id = aws_route_table.common["private"].id
    }
  }
}

/* 
 * VPC Endpoint Parameter
 */
locals {
  vpce_interface = {
    ecr_dkr = {
      create             = false
      subnet_ids         = [aws_subnet.common["private_c"].id]
      service_name       = "com.amazonaws.${data.aws_region.default.id}.ecr.dkr"
      security_group_ids = [module.vpc_endpoint.security_group_id]
    }
    ecr_api = {
      create             = false
      subnet_ids         = [aws_subnet.common["private_c"].id]
      service_name       = "com.amazonaws.${data.aws_region.default.id}.ecr.api"
      security_group_ids = [module.vpc_endpoint.security_group_id]
    }
    logs = {
      create             = false
      subnet_ids         = [aws_subnet.common["private_c"].id]
      service_name       = "com.amazonaws.${data.aws_region.default.id}.logs"
      security_group_ids = [module.vpc_endpoint.security_group_id]
    }
    # td_agent = {
    #   create = false
    #   subnet_ids = [aws_subnet.common["private_a"].id,aws_subnet.common["private_c"].id]
    #   service_name      = data.terraform_remote_state.stats_stg.outputs.td_vpc_endpoint_service_service_name
    #   security_group_ids = [module.vpc_endpoint.security_group_id]
    # }
  }
}

/* 
 * EIP
 */
# locals {
#   eip = {
#     prometheus_server = {
#       create      = false
#       instance_id = module.prometheus_server.instance_id
#     }
#     node_exporter = {
#       create      = false
#       instance_id = module.node_exporter.instance_id
#     }
#   }
# }

