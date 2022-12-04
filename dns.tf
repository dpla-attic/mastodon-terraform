data "aws_route53_zone" "site_dns_zone" {
  name = var.local_domain
}

locals {
  route53_zone_id = data.aws_route53_zone.site_dns_zone.zone_id
}