################################################################################
# Group
################################################################################

resource "aws_identitystore_group" "this" {
  for_each         = toset(var.groups)

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  display_name      = each.value.name
  description       = each.value.description
}

################################################################################
# User
################################################################################

resource "aws_identitystore_user" "this" {
  for_each = toset(var.users)

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  display_name      = join(" ", [each.value.name.given_name, each.value.name.family_name])
  user_name         = each.key

  name {
    family_name = each.value["name"]["family_name"]
    given_name  = each.value["name"]["given_name"]
  }
}

################################################################################
# Membership
################################################################################

resource "aws_identitystore_group_membership" "this" {
  for_each = toset(var.users_groups_membership)

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  group_id          = aws_identitystore_group.this[each.value["group"]].group_id
  member_id         = aws_identitystore_user.this[each.value["user"]].user_id
}
