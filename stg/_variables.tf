# variable "restriction_cloudfront_stg" {
#   type        = map(string)
#   description = "ALBへのアクセスを、CloudFront経由に限定するためのカスタムヘッダー"

#   default = {
#     key   = "X-From-Restriction-Cloudfront"
#     value = "TczzzPXeBsCsz3ksaaag"
#   }
# }

variable "prometheus_sg_inbound_rule" {
  description = "SGのインバウンドルールのポート"
  type        = list(string)
  default = [
    "80", "443", "22", "9090", "3000", "9100"
  ]
}

variable "start_rds" {
  description = "RDSインスタンスを作成する場合はtrue"
  type        = bool
  default     = false
}

variable "start_aurora" {
  description = "Auroraに関連するリソースを作成したい場合はtrue"
  type        = bool
  default     = false
}

variable "start_ec2_francfurt" {
  type    = bool
  default = false
}

variable "user_name" {
  description = "IAMユーザー名"
  type        = set(string)
  default = [
    "sato",
    "suzuki",
    "tanaka",
    "sato",
  ]
}

// mapは同じ型で定義しないといけない。
variable "example_map" {
  type = map(string)
  default = {
    key1 = "value1",
    key2 = "value2",
    key3 = "value3"
  }
}

// 数値型のmap
variable "example_map_numbers" {
  type = map(number)
  default = {
    key1 = 1,
    key2 = 2,
    key3 = 3
  }
}

// オブジェクトはプロパティごとに型を宣言する事で型を混在して扱える。
variable "multi_array" {
  type = object({
    property1 = string
    property2 = number
    property3 = bool
  })
  default = {
    property1 = "string value"
    property2 = 42
    property3 = true
  }
}

# Maintenance Mode -----------------------------------------
variable "full_maintenance" {
  description = "trueにすると全てのリクエストにメンテナンス画面を返す"
  type        = bool
  default     = false
}

variable "half_maintenance" {
  description = "trueにすると特定のIPを除いたリクエストにメンテナンス画面を返す"
  type        = bool
  default     = false
}

# WAF -----------------------------------------------------
variable "waf_region_count" {
  description = "trueにすると国別アクセスをCountするためのWAFが作成される"
  type        = bool
  default     = false
}

# EC2インスタンス -------------------------------------------
variable "create_web_instance" {
  description = "trueにするとwebサーバ用のEC2インスタンスが作成される"
  type        = bool
  default     = false
}

# EBS -----------------------------------------------------
variable "ebs_add_1" {
  description = "trueにすると単愛のEBSが作成される"
  type        = bool
  default     = false
}

# Nat Gateway ---------------------------------------------
variable "nat" {
  description = "trueにするとNAT GW関連のリソースが作成される"
  type        = bool
  default     = false
}

# VPCエンドポイント ---------------------------------------------
variable "vpc_endpoint_gw" {
  description = "trueにするゲートウェイ型のVPCエンドピント関連のリソースが作成される"
  type        = bool
  default     = false
}



# variable "dynamic_sg" {
#   description = "for_eachでの繰り返し用"
#   type = map(object(
#         {
#          port        = number
#          cidr_blocks = list(string)
#         }
#       )
#     )
#   }

# IAM --------------------------------------------------
variable "iam_user" {
  type = list(string)
  default = [
    "tanaka",
    "sato",
    "suzuki",
    "tanaka"
  ]
}

variable "iam_user_map" {
  type = map(string)
  default = {
    user1 = "tanaka",
    user2 = "sato",
    user3 = "suzuki",
    user1 = "takahashi"
  }
}

# ECR -------------------------------------------------
variable "repo_list" {
  description = "ECRリポジトリのリスト"
  type        = list(string)
  default = [
    "nginx",
    "actions-deploy",
  ]
}

# Listener Rule ---------------------------------------
variable "blue" {
  description = "ALB Listener Rule"
  type        = bool
  default     = true
}
