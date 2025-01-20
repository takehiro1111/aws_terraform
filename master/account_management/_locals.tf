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
      email      = data.aws_ssm_parameter.my_gmail_alias_address.value
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

/* 
 * SSM Pasrameter Store
 */
locals {
  ap_northeast_1 = {
    family_name = {
      name        = "/name/FamilyName"
      description = "苗字"
      type        = "String"
    }
    given_name = {
      name        = "/name/GiveNname"
      description = "名前"
      type        = "String"
    }
    org_id = {
      name        = "/id/organizations"
      description = "ユーザーネーム"
      type        = "SecureString"
    }
    slack_workspace_id = {
      name        = "/slack/personal/workspace_id"
      description = "個人用のSlackワークスペースID"
      type        = "SecureString"
    }
    slack_channel_id_aws_alert = {
      name        = "/slack/personal/channel_id"
      description = "個人用のSlackチャンネルID"
      type        = "SecureString"
    }
    my_gmail_address = {
      name        = "/mail/personal/gmail"
      description = "個人用のメールアドレス"
      type        = "SecureString"
    }
    my_gmail_alias_address = {
      name        = "/mail/personal/alias"
      description = "developmentアカウントで登録しているメールアドレス"
      type        = "SecureString"
    }
    company_mail_address = {
      name        = "/slack/company/mail_address"
      description = "会社用のメールアドレス"
      type        = "SecureString"
    }
  }
}
