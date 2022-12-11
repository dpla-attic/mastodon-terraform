resource "aws_ses_domain_identity" "ses_domain" {
  domain = var.local_domain
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = local.route53_zone_id
  name    = "_amazonses.${var.local_domain}"
  type    = "TXT"
  ttl     = "600"
  records = [join("", aws_ses_domain_identity.ses_domain.*.verification_token)]
}

resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  domain = join("", aws_ses_domain_identity.ses_domain.*.domain)
}

resource "aws_route53_record" "dkim_record" {
  count   = 3
  zone_id = local.route53_zone_id
  name    = "${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}._domainkey.${var.local_domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_ses_domain_mail_from" "mail_from" {
  domain           = aws_ses_domain_identity.ses_domain.domain
  mail_from_domain = "bounce.${var.local_domain}"
}

resource "aws_route53_record" "spf_mail_from" {
  zone_id = local.route53_zone_id
  name    = aws_ses_domain_mail_from.mail_from.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_route53_record" "mx_mail_from" {
  zone_id = local.route53_zone_id
  name    = aws_ses_domain_mail_from.mail_from.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.us-east-1.amazonses.com"]
}

resource "aws_route53_record" "spf_domain" {
  zone_id = local.route53_zone_id
  name    = var.local_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_ses_configuration_set" "ses_email_config" {
  name                       = "cloudwatch-configuration-set"
  reputation_metrics_enabled = true
}

resource "aws_ses_event_destination" "cloudwatch" {
  name                   = "event-destination-cloudwatch"
  configuration_set_name = aws_ses_configuration_set.ses_email_config.name
  enabled                = true
  matching_types         = ["send", "reject", "bounce", "complaint", "delivery", "renderingFailure"]

  cloudwatch_destination {
    default_value  = "default"
    dimension_name = "event"
    value_source   = "emailHeader"
  }
}

### SMTP

resource "aws_iam_user" "ses_smtp_user" {
  name = "ses-smtp-user-mastodon"
  path = "/"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ses_smtp_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ses:SendRawEmail"]
    resources = ["arn:aws:ses:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identity/${var.local_domain}"]
  }
}

resource "aws_iam_user_policy" "ses_smtp_user_assign_policy" {
  name   = "AmazonSesSendingAccess"
  user   = aws_iam_user.ses_smtp_user.name
  policy = data.aws_iam_policy_document.ses_smtp_policy.json
}

resource "aws_iam_access_key" "ses_smtp_user_access_key" {
  user = aws_iam_user.ses_smtp_user.name
}