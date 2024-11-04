# #########################################################
# # PermissionSet
# #########################################################
resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  name             = each.value.name
  description      = each.value.description
  instance_arn     = var.identity_store_arn
  session_duration = "PT2H"
}

resource "aws_ssoadmin_permissions_boundary_attachment" "this" {
  for_each = {
    for k, v in var.permission_sets : k => v
    if v.permissions_boundary_arn != null
  }

  instance_arn       = var.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  permissions_boundary {
    managed_policy_arn = each.value.permissions_boundary_arn
  }
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = {
    for k, v in var.permission_sets : k => v
    if v.managed_policy_arns != null
  }

  instance_arn       = var.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  managed_policy_arn = each.value.managed_policy_arns
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "this" {
  for_each = {
    for k, v in var.permission_sets : k => v
    if v.customer_managed_policy != null
  }

  instance_arn       = var.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  customer_managed_policy_reference {
    name = each.value.customer_managed_policy.name
    path = each.value.customer_managed_policy.path
  }
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = { for k, v in var.ssoadmin_account_assignment : k => v }

  instance_arn       = var.identity_store_arn
  permission_set_arn = each.value.permission_set_arn
  principal_id       = each.value.principal_id
  principal_type     = "GROUP"

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"
}
