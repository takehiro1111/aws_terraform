# WAF -----------------------------------------------------
variable "waf_region_count" {
  description = "trueにすると国別アクセスをCountするためのWAFが作成される"
  type        = bool
  default     = false
}

variable "waf_rule_regional_limit" {
  description = "falseにすると地域制限のルールが無効化になる。"
  type        = bool
  default     = false
}

variable "waf_regional_limit" {
  description = "trueにすると国別アクセスをCountするためのWAFが作成される"
  type        = bool
  default     = true
}
