#################################################
# Security Group from official modules
#################################################
module "nlb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  // SG
  name        = format("%s-%s-%s", "nlb", local.service, local.env)
  description = "SG for log routing"
  vpc_id      = module.vpc.vpc_id
  // Rule
  ingress_with_cidr_blocks = [for k, v in local.sg_object :
    {
      from_port   = v.from_port
      to_port     = v.to_port
      protocol    = v.protocol
      description = v.description
      cidr_blocks = v.cidr_blocks
    }
  ]

  ingress_with_source_security_group_id = [
    {
      from_port                = 0
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "From NLB"
      source_security_group_id = module.ecs.security_group_id
    }
  ]

  egress_rules = ["all-all"]
}


module "ecs" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  // SG
  name        = format("%s-%s-%s", "ecs", local.service, local.env)
  description = "ecs"
  vpc_id      = module.vpc.vpc_id

  // Rule
  ingress_with_source_security_group_id = [
    {
      from_port                = 0
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "From NLB"
      source_security_group_id = module.nlb.security_group_id
    }
  ]

  ingress_with_self = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow Inbound Self"
    }
  ]

  egress_rules = ["all-all"]
}
