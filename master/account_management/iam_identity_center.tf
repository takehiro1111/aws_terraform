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

  ssoadmin_account_assignment = {
    administrator_main = {
      permission_set_arn = module.iam_identity_center_permissionset.permission_set_arn.administrator
      principal_id = module.iam_identity_center_user_group_association.identitystore_group_arn.administrator
      account_id = data.aws_caller_identity.self.account_id
    }
    administrator_dev_1 = {
      permission_set_arn = module.iam_identity_center_permissionset.permission_set_arn.administrator
      principal_id = module.iam_identity_center_user_group_association.identitystore_group_arn.administrator
      account_id = "886436969838"
    }
  }
}

################################################################################
# Associating users and groups with permissionsets
################################################################################
module "iam_identity_center_user_group_association" {
  source             = "../../modules/iam_identity_center/membership"
  identity_store_id  = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]

  groups = {
    administrator = {
      name = "Admin"
      description = "Repository Manager"
    }
    support_user = {
      name = "SupportUser"
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
    takehiro1111 = ["administrator","support_user"]
  }
}
