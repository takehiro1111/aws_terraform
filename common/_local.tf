locals {
  servicename = "hashicorp"
  env         = "stg"
  repository  = "hashicorp"
  directory   = "sekigaku/hashicorp"

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
    module.value.hashicorp_subnet_ip.a_private,
    module.value.hashicorp_subnet_ip.c_private,
    module.value.hashicorp_subnet_ip.d_private,
  ]
}

locals {
  private_sb_ips2 = [
    module.value.hashicorp_subnet_ip.a_public,
    module.value.hashicorp_subnet_ip.c_public,
    module.value.hashicorp_subnet_ip.d_public,
  ]
}

# CloudFrontのカスタムエラーレスポンス
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

  # メンテモードをtrueにする場合は503エラーのカスタムエラーレスポンスを作成する。
  conditional_custom_error_responses = var.full_maintenance || var.half_maintenance ? [
    {
      error_caching_min_ttl = 10
      error_code            = 503
      response_code         = 503
      response_page_path    = "/maintenance/maintenance.html"
    }
  ] : []
}
