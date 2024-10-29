/* 
 * Default Tags
 */
locals {
  service_name = "account_management"
  repo         = "aws_terraform"
  dir          = "common/account_management"
}

/* 
 * Organizations Parameter 
 */
locals {
  members = {
    member_1 = {
      name      = substr(module.value.my_gmail_alias_address.member_1, 14, 14)
      email     = module.value.my_gmail_alias_address.member_1
      parent_id = aws_organizations_organizational_unit.ou["ou_2"].id
    }
  }

  ou = {
    ou_1 = {
      name      = trimsuffix(local.dir, "/account_management")
      parent_id = aws_organizations_organization.org.roots[0].id
    }
    ou_2 = {
      name      = "member"
      parent_id = aws_organizations_organization.org.roots[0].id
    }
  }

  aws_service_access_principals = [
    "access-analyzer.amazonaws.com",
    "health.amazonaws.com",
    "reporting.trustedadvisor.amazonaws.com",
    "sso.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "inspector2.amazonaws.com",
    "config.amazonaws.com",
    "detective.amazonaws.com",
    "securityhub.amazonaws.com",
    "ram.amazonaws.com",
    "wellarchitected.amazonaws.com",
    "member.org.stacksets.cloudformation.amazonaws.com",
    "storage-lens.s3.amazonaws.com",
    "reachabilityanalyzer.networkinsights.amazonaws.com",
    "cost-optimization-hub.bcm.amazonaws.com",
    "compute-optimizer.amazonaws.com",
    "guardduty.amazonaws.com",
    "malware-protection.guardduty.amazonaws.com",
    "account.amazonaws.com",
  ]
}
