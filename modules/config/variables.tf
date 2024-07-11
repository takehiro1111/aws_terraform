variable "name" {
  type = "string"
}

variable "recording_mode_overrides" {
  type = list(object({
    description         = string
    resource_types      = list(string)
    recording_frequency = string
  }))
  default = [
    {
      description         = "Only record EC2 network interfaces daily"
      resource_types      = ["AWS::EC2::NetworkInterface"]
      recording_frequency = "DAILY"
    }
  ]
}

variable "s3_bucket_name" {
  description = "Configで収集した履歴を保管するバケット"
  type = "string"
}

variable "config_rules" {
  type = list(object(
    
  ))
}
