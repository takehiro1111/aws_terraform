# Officeial Module -----------------------------------------
# refarence: https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/latest
module "aurora_mysql_takehiro1111_com" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.14.0"

  create = false

  ## Common Parameter
  name = "aurora-cluster-${local.env}"

  ## DB Subnet Group
  create_db_subnet_group = true
  db_subnet_group_name   = "aurora-${local.env}"
  subnets                = module.vpc_comp_stg.private_subnets

  ## Cluster
  cluster_use_name_prefix = false

  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.05.2"

  master_username                 = "hoge"
  master_password                 = "fugafuga"
  backup_retention_period         = 35
  preferred_backup_window         = "16:10-16:40"
  preferred_maintenance_window    = "sun:17:10-sun:17:40"
  storage_encrypted               = true
  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]
  deletion_protection             = true
  backtrack_window                = 86400
  manage_master_user_password     = false
  db_parameter_group_name         = "db-parameter-${local.env}"

  ## Cluster Instance(s)
  instance_class = "db.t4g.medium"
  instances = {
    0 = {}
    1 = {}
  }

  auto_minor_version_upgrade = false
  monitoring_interval        = 60

  ## Cluster Endpoint(s)
  endpoints = {
    reader = {
      identifier = "ro-${local.env}"
      type       = "READER"
    }
  }

  ## Cluster IAM Roles
  ## Enhanced Monitoring
  iam_role_use_name_prefix = false

  ## Autoscaling
  # autoscaling_enabled      = true
  # autoscaling_min_capacity = 1
  # autoscaling_max_capacity = 5

  ## Security Group
  security_group_use_name_prefix = false
  vpc_id                         = module.vpc_comp_stg.vpc_id

  security_group_rules = {
    ingress_rules = {
      cidr_blocks = [
        module.value.subnet_ips_comp_stg.a_private,
        module.value.subnet_ips_comp_stg.c_private,
      ]
      description = "MySQL/Aurora"
    },
    egress_rules = {
      type      = "egress"
      from_port = "0"
      to_port   = "0"
      protocol  = "-1"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
      description = "All protocols"
    },
  }

  ## Cluster Parameter Group
  create_db_cluster_parameter_group          = true
  db_cluster_parameter_group_name            = "rds-cluster-${local.env}"
  db_cluster_parameter_group_use_name_prefix = false
  db_cluster_parameter_group_description     = "RDS default cluster parameter group"
  db_cluster_parameter_group_family          = "aurora-mysql8.0"
  db_cluster_parameter_group_parameters = [
    {
      name  = "character_set_server",
      value = "utf8mb4",
    },
    {
      name  = "character_set_connection"
      value = "utf8mb4"
    },
    {
      name  = "character_set_database"
      value = "utf8mb4"
    },
    {
      name  = "character_set_results"
      value = "utf8mb4"
    },
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "collation_connection"
      value = "utf8mb4_general_ci"
    },
    {
      name  = "time_zone"
      value = "Asia/Tokyo"
    },
    {
      name  = "general_log"
      value = 0
    },
    {
      name  = "slow_query_log"
      value = 1
    },
    {
      name  = "log_output"
      value = "file"
    },
    ## 監査ログ関係
    {
      name  = "server_audit_logging"
      value = "1"
    },
    {
      name  = "server_audit_logs_upload"
      value = "1"
    },
    {
      name  = "server_audit_events"
      value = "connect,query,query_dcl,query_ddl,query_dml,table"
    },
    ## MySQLユーザ'rdsadmin'は特段監査ログに必要ないので記録しない。
    {
      apply_method = "immediate"
      name         = "server_audit_excl_users"
      value        = "rdsadmin"
    },
    ## Blue/Green Deploymentのため、binlog_formatをMIXEDに設定
    {
      apply_method = "pending-reboot"
      name         = "binlog_format"
      value        = "MIXED"
    }
  ]

  ## DB Parameter Group
  create_db_parameter_group          = true
  db_parameter_group_use_name_prefix = false
  db_parameter_group_description     = "RDS default DB parameter group"
  db_parameter_group_family          = "aurora-mysql8.0"
  db_parameter_group_parameters = [
    {
      name  = "max_connections"
      value = 1024
    }
  ]

  ## CloudWatch Log Group
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 0 // 無期限

  ## PerformanceInsight
  # performance_insights_enabled          = true
  # performance_insights_retention_period = 7
  # performance_insights_kms_key_id       = data.aws_kms_key.key_for_rds.arn
}
