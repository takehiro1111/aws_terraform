/* 
 * Default Tags
 */
locals {
  service_name = "account_management"
  repo         = "aws_terraform"
  dir          = "master/account_management"
}

/* 
 * Organizations Parameter 
 */
locals {
  members = {
    dev = {
      name       = "development"
      email      = module.value.my_gmail_alias_address.dev_takehiro11111
      parent_id  = aws_organizations_organizational_unit.ou["ou_2"].id
      account_id = data.terraform_remote_state.development_state.outputs.account_id
    }
  }

  ou = {
    ou_1 = {
      name      = "Master"
      parent_id = aws_organizations_organization.org.roots[0].id
    }
    ou_2 = {
      name      = "Development"
      parent_id = aws_organizations_organization.org.roots[0].id
    }
  }

  aws_service_access_principals = [
    "access-analyzer.${data.aws_partition.current.dns_suffix}",
    "health.${data.aws_partition.current.dns_suffix}",
    "reporting.trustedadvisor.${data.aws_partition.current.dns_suffix}",
    "sso.${data.aws_partition.current.dns_suffix}",
    "cloudtrail.${data.aws_partition.current.dns_suffix}",
    "inspector2.${data.aws_partition.current.dns_suffix}",
    "config.${data.aws_partition.current.dns_suffix}",
    "detective.${data.aws_partition.current.dns_suffix}",
    "securityhub.${data.aws_partition.current.dns_suffix}",
    "ram.${data.aws_partition.current.dns_suffix}",
    "wellarchitected.${data.aws_partition.current.dns_suffix}",
    "member.org.stacksets.cloudformation.${data.aws_partition.current.dns_suffix}",
    "storage-lens.s3.${data.aws_partition.current.dns_suffix}",
    "reachabilityanalyzer.networkinsights.${data.aws_partition.current.dns_suffix}",
    "cost-optimization-hub.bcm.${data.aws_partition.current.dns_suffix}",
    "compute-optimizer.${data.aws_partition.current.dns_suffix}",
    "guardduty.${data.aws_partition.current.dns_suffix}",
    "malware-protection.guardduty.${data.aws_partition.current.dns_suffix}",
    "account.${data.aws_partition.current.dns_suffix}",
  ]

  permission_sets = {
    administrator = {
      name = "Administrator"
    }
  }

  sso_managed_policy = {
    administrator = {
      policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
    }
  }
}
