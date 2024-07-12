variable "env" {
  description = "どの環境用の踏み台か"

  validation {
    condition     = var.env == "prod" || var.env == "stg"
    error_message = "Parameter 'env' must be either 'prod' or 'stg'."
  }
}

variable "iam_instance_profile" {}

variable "sg_name" {
  description = "SGの命名"
}

# variable "sg_inbound_rule" {
#   description = "SGのインバウンドルールのポート"
#   type        = list(string)
# }

variable "inastance_name" {
  description = "EC2インスタンスの識別子"
}

variable "root_volume_name" {
  description = "ルートEBSボリュームの識別子"
}

variable "vpc_id" {
  description = "VPCのID"
}

variable "subnet_id" {
  description = "サブネットのID"
}

variable "instance_type" {
  description = "EC2インスタンスタイプ"
  default     = "t3.nano"
}

variable "volume_type" {
  description = "EBSのボリュームタイプ"
  default     = "gp3"
}

variable "volume_size" {
  description = "EBSのボリュームサイズ"
  default     = 8
}

variable "idle_session_timeout" {
  description = "アイドル状態でのタイムアウト時間"
  default     = "30"
}

variable "max_session_duration" {
  description = "セッション有効期間"
  default     = "60"
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
  default     = "for-bastion-s3bucket"
}

variable "inline_policy" {
  description = "インラインポリシー"
  default     = null
}


## EBS
variable "create_tmp_ebs_resource" {
  description = "一時的にEBSを利用する場合"
  type        = bool
  default     = false
}

variable "availability_zone" {
  default = "ap-northeast-1c"
}

variable "ebs_size" {
  description = "EBSのサイズ"
  default     = 50
}

variable "ebs_type" {
  description = "EBSの種類"
  default     = "gp3"
}

variable "ebs_iops" {
  description = "EBSのiops ※メンテ作業などの際効率UPを目的に数値あげています(デフォルト：3000)"
  default     = 16000
}

variable "ebs_throughput" {
  description = "EBSのthroughput ※メンテ作業などの際効率UPを目的に数値あげています(デフォルト：125)"
  default     = 1000
}

variable "ebs_encrypted" {
  description = "EBSの暗号化設定"
  default     = true
}

variable "ebs_device_name" {
  description = "EBSのデバイス名"
  default     = "/dev/sdf"
}
