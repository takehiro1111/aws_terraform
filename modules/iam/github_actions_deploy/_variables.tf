variable "oidc_arn" {
  description = "OIDC ARN"
  type        = string
}

variable "github_actions_repo" {
  description = "Github Actions Repo"
  type        = list(string)
}
