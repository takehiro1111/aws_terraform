################################################################################
# Group
################################################################################
resource "aws_identitystore_group" "this" {
  for_each         = var.groups

  identity_store_id = var.identity_store_id
  display_name      = each.value.name
  description       = each.value.description
}

################################################################################
# User
################################################################################
resource "aws_identitystore_user" "this" {
  for_each = var.users

  identity_store_id = var.identity_store_id
  display_name      = join(".", [each.value.name.given_name, each.value.name.family_name])
  user_name         = each.key

  name {
    family_name = each.value.name.family_name
    given_name  = each.value.name.given_name
  }

  dynamic "emails" {
    for_each = each.value.emails
    content {
      value = emails.value
    }
  }
}

################################################################################
# Associating users and groups with permissionsets
################################################################################
resource "aws_identitystore_group_membership" "this" {
  for_each = {
    for pair in flatten([
      for user, groups in var.memberships : [
        for group in groups : {
          user  = user
          group = group
        }
      ]
    ]) : "${pair.user}-${pair.group}" => pair
  }

  identity_store_id = var.identity_store_id
  group_id  = aws_identitystore_group.this[each.value.group].group_id
  member_id = aws_identitystore_user.this[each.value.user].user_id
}
