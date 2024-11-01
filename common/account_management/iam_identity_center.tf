#########################################################
# IAM Identity Center
#########################################################
data "aws_ssoadmin_instances" "sso" {}

// IDPとしてCognitoを先に作成したい。(2024/10/30)
# resource "aws_ssoadmin_application" "sso" {
#   name                     = "example"
#   application_provider_arn = "arn:aws:sso::aws:applicationProvider/custom"
#   instance_arn             = tolist(data.aws_ssoadmin_instances.sso.arns)[0]

#   portal_options {
#     visibility = "ENABLED"
#     sign_in_options {
#       application_url = "http://example.com"
#       origin          = "APPLICATION"
#     }
#   }
# }
