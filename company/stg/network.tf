/* 
 * takehiro1111.com
 */
module "route53_zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "5.0.0"

  create = true
  zones = {
    comp_takehiro1111_com = {
      force_destroy = true
      domain_name   = "comp.${module.value.takehiro1111_com}"
    }
  }
}

module "route53_records_takehiro1111_com" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "5.0.0"

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
  ]
}
