#########################################################
# Organizations
#########################################################
resource "aws_organizations_organization" "org" {
  aws_service_access_principals = local.aws_service_access_principals
  enabled_policy_types          = ["SERVICE_CONTROL_POLICY", "TAG_POLICY"]
  feature_set                   = "ALL"
}

resource "aws_organizations_account" "org_member_account" {
  for_each = {
    for key, value in local.members : key => {
      for inner_key, inner_value in value : inner_key => inner_value
    }
  }

  name                       = each.value.name
  email                      = each.value.email
  parent_id                  = each.value.parent_id
  iam_user_access_to_billing = "DENY"
  role_name                  = "OrganizationAccountAccessRole"

  tags = {
    Name = each.value.name
  }
}

resource "aws_organizations_organizational_unit" "ou" {
  for_each = {
    for key, value in local.ou : key => {
      for inner_key, inner_value in value : inner_key => inner_value
    }
  }

  name      = each.value.name
  parent_id = each.value.parent_id
}

/* 
 * 委任管理アカウントの指定
 */
// IAM Identity Centerで管理後にapply予定(2024/11/1)
# resource "aws_organizations_delegated_administrator" "security_hub" {
#   for_each = {
#     for key, value in local.members : key => {
#       for inner_key, inner_value in value : inner_key => inner_value
#     }
#   }

#   account_id        = each.value.account_id
#   service_principal = "securityhub.amazonaws.com"
# }
