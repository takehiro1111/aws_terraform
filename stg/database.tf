#==========================================
# DynamoDB
#==========================================
resource "aws_dynamodb_table" "tfstate_locks" {
  name         = "tfstate-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

#==========================================
# RDS for MYSQL
#==========================================
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
  name = "mysql-8"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id
  ]
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

# Aurora -----------------------------------------
resource "aws_db_cluster_snapshot" "mysql_8" {
  db_cluster_identifier          = "aurora-cluster" // aws_rds_clusterを削除した際でも参照先を失わないよう意図的にハードコードしている。
  db_cluster_snapshot_identifier = "test-snapshot-20240218"
}

data "aws_db_cluster_snapshot" "mysql_8" {
  most_recent           = true
  db_cluster_identifier = "aurora-cluster"
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
  engine_version                  = "5.7.mysql_aurora.2.12.1"
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.mysql_8_aurora.name
  db_subnet_group_name            = aws_db_subnet_group.mysql_8.name
  delete_automated_backups        = true  //使用予定ないため削除後にシステムバックアップは不要
  deletion_protection             = false //テスト用のため削除保護は設定しない。
  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]
  skip_final_snapshot             = true

  backup_retention_period     = 31
  backtrack_window            = 259200 // 1週間前まで巻き戻し可能  
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
  instance_class     = "db.t3.small"
  engine             = aws_rds_cluster.mysql_8[count.index].engine
  engine_version     = aws_rds_cluster.mysql_8[count.index].engine_version

  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.mysql_8.name
  ca_cert_identifier   = "rds-ca-rsa2048-g1"


  auto_minor_version_upgrade = false
  db_parameter_group_name    = aws_db_parameter_group.mysql_8_aurora.name

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  performance_insights_kms_key_id       = "arn:aws:kms:ap-northeast-1:${data.aws_caller_identity.current.account_id}:key/6208518c-69f1-460a-9e58-0d3cee35a5f5"
}

resource "aws_rds_cluster_parameter_group" "mysql_8_aurora" {
  name        = local.idetifier_aurora_cluster
  family      = "aurora-mysql5.7"
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
  family      = "aurora-mysql5.7"
  description = "RDS default DB parameter group"
  parameter {
    name  = "max_connections"
    value = 1024
  }
}
