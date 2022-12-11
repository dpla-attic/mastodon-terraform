resource "aws_kms_key" "log_key" {
  description             = "Log key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_cloudwatch_log_group" "mastodon_log_group" {
  name              = "Mastodon"
  skip_destroy      = "true"
  retention_in_days = 7
  kms_key_id        = aws_kms_key.log_key.arn
}