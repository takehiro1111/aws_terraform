variable "env" {
  description = "どの環境用の踏み台か"
  type        = string

  validation {
    condition     = var.env == "prod" || var.env == "stg"
    error_message = "Parameter 'env' must be either 'prod' or 'stg'."
  }
}

variable "vpc_id" {
  description = "VPCのID"
  type        = string
}

variable "subnet_id" {
  description = "サブネットのID"
  type        = string
}

variable "instance_type" {
  description = "EC2インスタンスタイプ"
  type        = string
  default     = "t3.nano"
}

variable "volume_type" {
  description = "EBSのボリュームタイプ"
  type        = string
  default     = "gp3"
}

variable "volume_size" {
  description = "EBSのボリュームサイズ"
  type        = number
  default     = 8
}

variable "idle_session_timeout" {
  description = "アイドル状態でのタイムアウト時間"
  type        = number
  default     = 30
}

variable "max_session_duration" {
  description = "セッション有効期間"
  type        = number
  default     = 60
}

variable "create_common_resource" {
  description = "全環境共通リソースの作成有無"
  type        = bool
  default     = false
}

variable "iam_role_inlinepolicy_resources" {
  description = "module.iam_role_thisのinline_policy内のリソース"
  type        = list(string)
  default     = []
}

## EBS
variable "create_tmp_ebs_resource" {
  description = "一時的にEBSを利用する場合"
  type        = bool
  default     = false
}

variable "availability_zone" {
  type    = string
  default = "ap-northeast-1c"
}

variable "ebs_size" {
  description = "EBSのサイズ"
  type        = number
  default     = 50
}

variable "ebs_type" {
  description = "EBSの種類"
  type        = string
  default     = "gp3"
}

variable "ebs_iops" {
  description = "EBSのiops ※メンテ作業などの際効率UPを目的に数値あげています(デフォルト：3000)"
  type        = number
  default     = 16000
}

variable "ebs_throughput" {
  description = "EBSのthroughput ※メンテ作業などの際効率UPを目的に数値あげています(デフォルト：125)"
  type        = number
  default     = 1000
}

variable "ebs_encrypted" {
  description = "EBSの暗号化設定"
  type        = bool
  default     = true
}

variable "ebs_device_name" {
  description = "EBSのデバイス名"
  type        = string
  default     = "/dev/sdf"
}