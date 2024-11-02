#########################################################
# IAM Identity Center
#########################################################
/* 
 * Configuring an SSO instance manually in the Console
 */
data "aws_ssoadmin_instances" "sso" {}

#########################################################
# Permission Set
#########################################################
module "iam_identity_center_permissionset" {
  source             = "../../modules/iam_identity_center/permission_set"
  identity_store_id  = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
  identity_store_arn = tolist(data.aws_ssoadmin_instances.sso.arns)[0]

  permission_sets = {
    administrator = {
      name                     = "Administrator"
      description              = "Permissions for Administrator"
      permissions_boundary_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
      managed_policy_arns      = "arn:aws:iam::aws:policy/AdministratorAccess"
    },
    support_user = {
      name                     = "SupportUser"
      description              = "Permissions for SupportUser"
      permissions_boundary_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      managed_policy_arns      = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      supportUser_custom_policy = {
        name        = "SupportUser_CustomPolicy"
        description = "Custom policy for SupportUser"
        path        = "/"
        policy_statement = [{
          Action   = "s3:*",
          Effect   = "Allow",
          Resource = "*"
        }]
      }
    }
  }
}


# resource "aws_ssoadmin_permissions_boundary_attachment" "managed_policy" {
#   instance_arn       = aws_ssoadmin_permission_set.sso.instance_arn
#   permission_set_arn = aws_ssoadmin_permission_set.sso.arn
#   permissions_boundary {

#     dynamic "customer_managed_policy_reference" {
#       for_each = { for k, v in local.customer_managed_policy_reference : k => v if v.create }
#       content {
#         name = aws_iam_policy.example.name
#         path = "/"
#       }
#     }
#   }
# }

/* 
 * Assign a permission set to a user or group
 */
# resource "aws_ssoadmin_account_assignment" "sso" {
#   instance_arn       = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
#   permission_set_arn = aws_ssoadmin_permission_set.sso.arn

#   principal_id   = data.aws_identitystore_group.example.group_id
#   principal_type = "GROUP"

#   target_id   = "123456789012"
#   target_type = "AWS_ACCOUNT"
# }



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
