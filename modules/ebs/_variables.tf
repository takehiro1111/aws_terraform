variable "volume_az" {
  description = "アタッチ先のEC2インスタンスを置いているアベイラビリティゾーンの指定"
  type        = string
}

variable "volume_size" {
  description = "EBSボリュームのサイズ指定"
  type        = number
}

variable "volume_encrypted" {
  description = "EBSボリュームの暗号化の有無を指定"
  type        = bool
  default     = true
}

variable "volume_name" {
  description = "EBSボリュームの名前を指定"
  type        = string
}

variable "device_name" {
  description = "EBSボリュームのデバイス名を指定"
  type        = number
}

variable "instance_id" {
  description = "アタッチ先のEC2インスタンスIDを指定"
  type        = string
}

variable "stop_instance_before_detaching" {
  description = "EC2インスタンスが停止したことを確認した後、EBSボリュームの切り離し処理を実行するよう指定"
  type        = bool
  default     = true
}

