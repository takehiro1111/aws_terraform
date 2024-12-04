variable "env" {
  description = "どの環境用の踏み台か"

  validation {
    condition     = var.env == "prod" || var.env == "stg"
    error_message = "Parameter 'env' must be either 'prod' or 'stg'."
  }
}


# variable "ec2_instance" {
#   description = "EC2に直接設定するパラメータ"
#   type = object({
#     state = string
#     inastance_name = string
#     ami = string
#     instance_type = string
#     subnet_id = string
#     vpc_security_group_ids = list(string)
#     iam_instance_profile = string
#     associate_public_ip_address = bool
#     create_additonal_ebs_block_device = bool
#     root_block_device = object({
#       type = string
#       size = number
#       delete_on_termination = bool
#       encrypted = bool
#     })
#   })
# }

variable "create_instance" {
  description = "EC2に直接設定するパラメータ"
  type        = any
  default = {
    create = false
  }
}

variable "ec2_instance" {
  description = "EC2に直接設定するパラメータ"
  type        = any
}


# variable "iam_instance_profile" {}

# variable "sg_name" {
#   description = "SGの命名"
# }

# variable "inastance_name" {
#   description = "EC2インスタンスの識別子"
# }

# variable "root_volume_name" {
#   description = "ルートEBSボリュームの識別子"
# }

# variable "vpc_id" {
#   description = "VPCのID"
# }

# variable "ami" {
#   description = "AMI"
# }

# variable "associate_public_ip_address" {
#   type = bool
#   default = true
# }

# variable "create_additonal_ebs_block_device" {
#   type = bool
#   default = false
# }

# variable "subnet_id" {
#   description = "サブネットのID"
# }

# variable "instance_type" {
#   description = "EC2インスタンスタイプ"
#   default     = "t3.nano"
# }

# variable "volume_type" {
#   description = "EBSのボリュームタイプ"
#   default     = "gp3"
# }

# variable "volume_size" {
#   description = "EBSのボリュームサイズ"
#   default     = 8
# }

variable "idle_session_timeout" {
  description = "アイドル状態でのタイムアウト時間"
  default     = "60"
}

variable "max_session_duration" {
  description = "セッション有効期間"
  default     = "120"
}

variable "create_common_resource" {
  description = "全環境共通リソースの作成有無"
  type        = bool
  default     = false
}

variable "create_inline_policy" {
  description = "インラインポリシー"
  type        = bool
  default     = false
}

variable "inline_policy_name" {
  description = "インラインポリシーの名称"
  type        = string
  default     = null
}

variable "inline_policy" {
  description = "インラインポリシー"
  type        = string
  default     = null
}

## EBS
# variable "create_tmp_ebs_resource" {
#   description = "一時的にEBSを利用する場合"
#   type        = bool
#   default     = false
# }

# variable "availability_zone" {
#   default = "ap-northeast-1c"
# }

# variable "ebs_size" {
#   description = "EBSのサイズ"
#   default     = 50
# }

# variable "ebs_type" {
#   description = "EBSの種類"
#   default     = "gp3"
# }

# variable "ebs_iops" {
#   description = "EBSのiops ※メンテ作業などの際効率UPを目的に数値あげています(デフォルト：3000)"
#   default     = 16000
# }

# variable "ebs_throughput" {
#   description = "EBSのthroughput ※メンテ作業などの際効率UPを目的に数値あげています(デフォルト：125)"
#   default     = 1000
# }

# variable "ebs_encrypted" {
#   description = "EBSの暗号化設定"
#   default     = true
# }

# variable "ebs_device_name" {
#   description = "EBSのデバイス名"
#   default     = "/dev/sdf"
# }
