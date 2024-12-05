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

variable "user_data" {
  description = "EC2にinstallするコマンド群"
  type        = any
  default     = null
}

variable "metadata_options" {
  description = "EC2にinstallするコマンド群"
  type        = any
  default     = null
}
