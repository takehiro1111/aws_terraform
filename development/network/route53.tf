#####################################################
# Route53
#####################################################
/* 
 * takehiro1111.com
 */
module "route53_zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "4.1.0"

  create = true
  zones = {
    takehiro1111_com = {
      force_destroy = true
      domain_name   = module.value.takehiro1111_com
    }
  }
}

module "route53_records_takehiro1111_com" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "4.1.0"

  create    = true
  zone_id   = module.route53_zones.route53_zone_zone_id.takehiro1111_com
  zone_name = module.route53_zones.route53_zone_name.takehiro1111_com

  records = [
    {
      name    = trimprefix(module.route53_zones.route53_zone_name.takehiro1111_com, module.value.takehiro1111_com)
      type    = "NS"
      ttl     = 300
      records = module.route53_zones.route53_zone_name_servers.takehiro1111_com
    },
    {
      name = trimprefix(module.route53_zones.route53_zone_name.takehiro1111_com, module.value.takehiro1111_com)
      type = "SOA"
      ttl  = 300
      records = [
        "${module.route53_zones.primary_name_server.takehiro1111_com} awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
      ]
    },
    {
      name = trimsuffix(module.value.cdn_takehiro1111_com, ".${module.value.takehiro1111_com}")
      type = "A"
      alias = {
        name                   = module.cdn_takehiro1111_com.cloudfront_distribution_domain_name
        zone_id                = module.cdn_takehiro1111_com.cloudfront_distribution_hosted_zone_id
        evaluate_target_health = false
      }
    },
    {
      name = trimsuffix(module.value.api_takehiro1111_com, ".${module.value.takehiro1111_com}")
      type = "A"
      alias = {
        name                   = module.cloudfront_api_takehiro1111_com.cloudfront_distribution_domain_name
        zone_id                = module.cloudfront_api_takehiro1111_com.cloudfront_distribution_hosted_zone_id
        evaluate_target_health = false
      }
    },
  ]
}

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
