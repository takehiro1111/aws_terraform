#########################################################
# Organizations
#########################################################
/* 
 * Organizations
 */
resource "aws_organizations_organization" "org" {
  aws_service_access_principals = local.aws_service_access_principals
  enabled_policy_types          = ["SERVICE_CONTROL_POLICY", "TAG_POLICY"]
  feature_set                   = "ALL"
}

/* 
 * Organizations Unit
 */
resource "aws_organizations_organizational_unit" "ou" {
  for_each = { for k , v in local.ou : k => v }

  name      = each.value.name
  parent_id = each.value.parent_id
}

/* 
 * Organizations Member Accounts
 */
resource "aws_organizations_account" "org_member_account" {
  for_each = { for k , v in local.members : k => v }

  name                       = each.value.name
  email                      = each.value.email
  parent_id                  = each.value.parent_id
  iam_user_access_to_billing = "DENY"
  role_name                  = "OrganizationAccountAccessRole"

  tags = {
    Name = each.value.name
  }
}

/* 
 * Organizations Delegated Administrator Accounts
 */
# resource "aws_organizations_delegated_administrator" "security_hub" {
#   for_each = { for k , v in local.members : k => v }

#   account_id        = each.value.account_id
#   service_principal = "securityhub.amazonaws.com"
# }
