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

  permission_sets = {
    administorator = {
      name = "Administorator"
    }
  }

  sso_managed_policy = {
    administorator = {
      policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
    }
  }
}

/* 
 * AWS Config Parameter 
 */
locals {
  config_aggregate_authorization = {
    development_ap_northeast_1 = {
      account_id = data.terraform_remote_state.development_state.outputs.account_id
      region     = data.aws_region.default.name
    }
    development_us_east_1 = {
      account_id = data.terraform_remote_state.development_state.outputs.account_id
      region     = data.aws_region.us_east_1.name
    }
  }
}
