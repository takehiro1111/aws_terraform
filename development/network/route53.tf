#####################################################
# Route53
#####################################################
/* 
 * takehiro1111.com
 */
module "route53_zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "6.1.1"

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
  version = "6.1.1"

  create     = true
  zone_id    = module.route53_zones.route53_zone_zone_id.takehiro1111_com
  zone_name  = module.route53_zones.route53_zone_name.takehiro1111_com
  depends_on = [module.route53_zones]

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
    # {
    #   name = trimsuffix(module.value.prometheus_takehiro1111_com, ".${module.value.takehiro1111_com}")
    #   type = "A"
    #   alias = {
    #     name                   = module.cloudfront_prometheus_takehiro1111_com.cloudfront_distribution_domain_name
    #     zone_id                = module.cloudfront_prometheus_takehiro1111_com.cloudfront_distribution_hosted_zone_id
    #     evaluate_target_health = false
    #   }
    # },
    # {
    #   name = trimsuffix(module.value.grafana_takehiro1111_com, ".${module.value.takehiro1111_com}")
    #   type = "A"
    #   alias = {
    #     name                   = module.cloudfront_grafana_takehiro1111_com.cloudfront_distribution_domain_name
    #     zone_id                = module.cloudfront_grafana_takehiro1111_com.cloudfront_distribution_hosted_zone_id
    #     evaluate_target_health = false
    #   }
    # },
    # {
    #   name = trimsuffix(module.value.locust_takehiro1111_com, ".${module.value.takehiro1111_com}")
    #   type = "A"
    #   alias = {
    #     name                   = module.cloudfront_locust_takehiro1111_com.cloudfront_distribution_domain_name
    #     zone_id                = module.cloudfront_locust_takehiro1111_com.cloudfront_distribution_hosted_zone_id
    #     evaluate_target_health = false
    #   }
    # },
    {
      name = trimsuffix(module.value.func_takehiro1111_com, ".${module.value.takehiro1111_com}")
      type = "A"
      alias = {
        name                   = module.cloudfront_func_takehiro1111_com.cloudfront_distribution_domain_name
        zone_id                = module.cloudfront_func_takehiro1111_com.cloudfront_distribution_hosted_zone_id
        evaluate_target_health = false
      }
    },
    // 別アカウントでLocustを検証したいため、ドメインの移譲対応を行なっている。(2024/12/26)
    # {
    #   name = trimsuffix("common-dev.${module.value.takehiro1111_com}", ".${module.value.takehiro1111_com}")
    #   type = "NS"
    #   ttl  = 300
    #   records = [
    #     "ns-1954.awsdns-52.co.uk",
    #     "ns-716.awsdns-25.net",
    #     "ns-1464.awsdns-55.org",
    #     "ns-327.awsdns-40.com"
    #   ]
    # },
    # # {
    #   name = trimsuffix(module.value.api_takehiro1111_com, ".${module.value.takehiro1111_com}")
    #   type = "A"
    #   alias = {
    #     name                   = module.cloudfront_api_takehiro1111_com.cloudfront_distribution_domain_name
    #     zone_id                = module.cloudfront_api_takehiro1111_com.cloudfront_distribution_hosted_zone_id
    #     evaluate_target_health = false
    #   }
    # },
    {
      name = "comp"
      type = "NS"
      ttl  = 300
      records = [
        "ns-116.awsdns-14.com",
        "ns-945.awsdns-54.net",
        "ns-1584.awsdns-06.co.uk",
        "ns-1078.awsdns-06.org"
      ]
    }
  ]
}
