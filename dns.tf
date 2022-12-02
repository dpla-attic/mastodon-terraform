data "aws_route53_zone" "site_dns_zone" {
  name = var.local_domain
}