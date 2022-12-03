resource "aws_acm_certificate" "mastodon_cert" {
  domain_name       = var.local_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation_records" {
  for_each = {
    for dvo in aws_acm_certificate.mastodon_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.site_dns_zone.zone_id
}

resource "aws_acm_certificate_validation" "mastodon_cert_validation" {
  certificate_arn         = aws_acm_certificate.mastodon_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_records : record.fqdn]
}