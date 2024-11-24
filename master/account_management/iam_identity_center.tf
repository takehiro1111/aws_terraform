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
      name                     = local.permission_sets.administrator.name
      description              = "Permissions for Administrator"
      permissions_boundary_arn = local.sso_managed_policy.administrator.policy_arn
      managed_policy_arns      = local.sso_managed_policy.administrator.policy_arn
    },
    support_user = {
      name                     = "SupportUser"
      description              = "Permissions for SupportUser"
      permissions_boundary_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      managed_policy_arns      = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      customer_managed_policy = {
        name = aws_iam_policy.support_user_customer_managed_policy.name
        path = "/"
      }
    }
  }

  ssoadmin_account_assignment = {
    administrator_master = {
      permission_set_arn = module.iam_identity_center_permissionset.permission_set_arn.administrator
      principal_id       = module.iam_identity_center_user_group_association.identitystore_group_arn.administrator
      account_id         = data.aws_caller_identity.self.account_id
    }
    administrator_development = {
      permission_set_arn = module.iam_identity_center_permissionset.permission_set_arn.administrator
      principal_id       = module.iam_identity_center_user_group_association.identitystore_group_arn.administrator
      account_id         = data.terraform_remote_state.development_state.outputs.account_id
    }
  }
}

################################################################################
# Associating users and groups with permissionsets
################################################################################
module "iam_identity_center_user_group_association" {
  source            = "../../modules/iam_identity_center/membership"
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]

  groups = {
    administrator = {
      name        = "Admin"
      description = "Repository Manager"
    }
    support_user = {
      name        = "SupportUser"
      description = "Repository Manager"
    }
  }

  users = {
    takehiro1111 = {
      name = {
        family_name = substr(module.value.name_takehiro1111, 9, 8)
        given_name  = substr(module.value.name_takehiro1111, 0, 8)
      }
      eamils = [
        module.value.my_gmail_address
      ]
    }
  }

  memberships = {
    takehiro1111 = ["administrator", "support_user"]
  }
}

#########################################################
# IAM Policy of Permission Set
#########################################################
resource "aws_iam_policy" "support_user_customer_managed_policy" {
  name        = "supportuser-customer-managed-policy"
  description = "supportuser-customer-managed-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
        ]
        Effect   = "Deny"
        Resource = data.terraform_remote_state.master_state.outputs.s3_bucket_arn_tfstate
      },
    ]
  })
}
