##########################################################
# EC2 Instance
##########################################################
variable "create_web_server" {
  description = "Webサーバーを作成する場合はtrue"
  type        = bool
  default     = false
}
