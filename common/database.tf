#####################################################
# DynamoDB
#####################################################
resource "aws_dynamodb_table" "tfstate_locks" {
  name         = "tfstate-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

#####################################################
# RDS
#####################################################
# Random String -------------------------------
resource "random_string" "mysql_8" {
  length  = 16
  special = false
}

# Parameter Group -----------------------------
resource "aws_db_parameter_group" "mysql_8" {
  name   = "mysql-8"
  family = "mysql8.0"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

# Option Group --------------------------------
resource "aws_db_option_group" "mysql_8" {
  name                 = "mysql-8"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}

# Subnet Group ---------------------------------
resource "aws_db_subnet_group" "mysql_8" {
  name       = "mysql-8"
  subnet_ids = module.vpc_common.private_subnets
}

# RDS Instance ---------------------------------
resource "aws_db_instance" "mysql_8" {
  count = var.start_rds ? 1 : 0

  identifier             = "hcl-mysql8-${count.index}"
  db_subnet_group_name   = aws_db_subnet_group.mysql_8.name
  vpc_security_group_ids = [module.sg_mysql.security_group_id]
  engine                 = "mysql"
  engine_version         = "8.0.28"
  instance_class         = "db.t3.micro"

  #db_name = "" // インスタンス稼働後にSQLで作成のため設定しない
  username = "admin"
  password = random_string.mysql_8.result

  allocated_storage     = 20
  max_allocated_storage = 0
  storage_type          = "gp2"
  storage_encrypted     = false

  multi_az = false
  port     = 3306

  parameter_group_name = aws_db_parameter_group.mysql_8.name
  option_group_name    = aws_db_option_group.mysql_8.name

  backup_window              = "04:00-05:00"
  backup_retention_period    = 7
  maintenance_window         = "Mon:05:00-Mon:08:00"
  auto_minor_version_upgrade = false

  deletion_protection = false
  skip_final_snapshot = true

  apply_immediately   = true
  monitoring_interval = 0

  tags = {
    Name = "hcl-mysql8"
  }
}

#####################################################
# Aurora
#####################################################
# resource "aws_db_cluster_snapshot" "mysql_8" {
#   db_cluster_identifier          = "aurora-cluster" // aws_rds_clusterを削除した際でも参照先を失わないよう意図的にハードコードしている。
#   db_cluster_snapshot_identifier = "test-snapshot-20240218"
# }

/*
 * RDS用のkey(KMS管理)
 */
data "aws_kms_key" "key_for_rds" {
  key_id = "alias/aws/rds"
}

resource "aws_rds_cluster" "mysql_8" {
  count = var.start_aurora ? 1 : 0

  cluster_identifier = local.idetifier_aurora_cluster

  database_name          = "hoge"
  master_username        = "admin"
  master_password        = "hogehoge" // 作成後に変更
  port                   = 3306
  vpc_security_group_ids = [module.sg_mysql.security_group_id]

  storage_encrypted = true
  #snapshot_identifier = data.aws_db_cluster_snapshot.mysql_8.id // スナップショットを復元する際に使用

  engine                          = "aurora-mysql"
  engine_mode                     = "provisioned" // デフォルト設定
  engine_version                  = "8.0.mysql_aurora.3.06.0"
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.mysql_8_aurora.name
  db_subnet_group_name            = aws_db_subnet_group.mysql_8.name
  delete_automated_backups        = true  //使用予定ないため削除後にシステムバックアップは不要
  deletion_protection             = false //テスト用のため削除保護は設定しない。
  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]
  skip_final_snapshot             = true // 削除の際に手動スナップショットを取得しなくても削除可能にする

  backup_retention_period     = 31
  backtrack_window            = 259200 // 最大1週間前まで巻き戻し可能  
  availability_zones          = ["ap-northeast-1a", "ap-northeast-1c", ]
  apply_immediately           = true
  allow_major_version_upgrade = false

  preferred_backup_window      = "18:00-18:30"
  preferred_maintenance_window = "Sun:19:00-Sun:19:30"

  tags = {
    Name = local.idetifier_aurora_cluster
  }

  lifecycle {
    ignore_changes = [master_password, availability_zones]
  }
}

resource "aws_rds_cluster_instance" "mysql_8" {
  count = var.start_aurora ? 1 : 0

  identifier         = "aurora-cluster-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.mysql_8[count.index].id
  instance_class     = "db.t4g.medium"
  engine             = aws_rds_cluster.mysql_8[count.index].engine
  engine_version     = aws_rds_cluster.mysql_8[count.index].engine_version

  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.mysql_8.name
  ca_cert_identifier   = "rds-ca-rsa2048-g1"


  auto_minor_version_upgrade = false
  db_parameter_group_name    = aws_db_parameter_group.mysql_8_aurora.name

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  performance_insights_kms_key_id       = data.aws_kms_key.key_for_rds.arn
}

resource "aws_rds_cluster_parameter_group" "mysql_8_aurora" {
  name        = local.idetifier_aurora_cluster
  family      = "aurora-mysql8.0"
  description = "RDS default cluster parameter group"
  parameter {
    name  = "collation_connection"
    value = "utf8mb4_general_ci"
  }
  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }
  parameter {
    name  = "general_log"
    value = 0
  }
  parameter {
    name  = "slow_query_log"
    value = 1
  }
  parameter {
    name  = "log_output"
    value = "file"
  }
  parameter {
    name  = "server_audit_events"
    value = "connect,query,query_dcl,query_ddl,query_dml,table"
  }
  parameter {
    name  = "server_audit_logging"
    value = "1"
  }
  parameter {
    name  = "server_audit_logs_upload"
    value = "1"
  }
  # MySQLユーザ'rdsadmin'は特段監査ログに必要ないので記録しない。
  parameter {
    apply_method = "immediate"
    name         = "server_audit_excl_users"
    value        = "rdsadmin"
  }
}

resource "aws_db_parameter_group" "mysql_8_aurora" {
  name        = local.idetifier_aurora_cluster
  family      = "aurora-mysql8.0"
  description = "RDS default DB parameter group"
  parameter {
    name  = "max_connections"
    value = 1024
  }
}

# Officeial Module -----------------------------------------
# refarence: https://registry.terraform.io/modules/terraform-aws-modules/rds-aurora/aws/latest
module "official_module_aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.10.0"

  create = false

  ## Common Parameter
  name = "aurora-cluster-${local.env}"

  ## DB Subnet Group
  create_db_subnet_group = true
  db_subnet_group_name   = "aurora-${local.env}"
  subnets                = module.vpc_common.private_subnets

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
  vpc_id                         = module.vpc_common.vpc_id

  security_group_rules = {
    ingress_rules = {
      cidr_blocks = [
        module.value.subnet_ip_common.a_private,
        module.value.subnet_ip_common.c_private,
        module.value.subnet_ip_common.a_public,
        module.value.subnet_ip_common.c_public,
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
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  performance_insights_kms_key_id       = data.aws_kms_key.key_for_rds.arn
}
