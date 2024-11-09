#####################################################
# ACM
#####################################################
## us-east-1
module "acm_takehiro1111_com_us_east_1" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  # aws_acm_certificate
  create_certificate        = true
  domain_name               = module.value.wildcard_takehiro1111_com
  subject_alternative_names = [module.value.takehiro1111_com]
  validation_method         = "DNS"

  # aws_route53_record
  create_route53_records = true
  zone_id                = module.route53_zones.route53_zone_zone_id.takehiro1111_com

  # aws_acm_certificate_validation
  wait_for_validation = true

  providers = {
    aws = aws.us-east-1
  }
}

## ap-northeast-1
module "acm_takehiro1111_com_ap_northeast_1" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  # aws_acm_certificate
  create_certificate        = true
  domain_name               = module.value.wildcard_takehiro1111_com
  subject_alternative_names = [module.value.takehiro1111_com]
  validation_method         = "DNS"

  # aws_route53_record
  create_route53_records = true
  zone_id                = module.route53_zones.route53_zone_zone_id.takehiro1111_com

  # aws_acm_certificate_validation
  wait_for_validation = false
}
