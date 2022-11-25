resource "aws_cloudwatch_log_group" "mastodon_log_group" {
  name              = "Mastodon"
  skip_destroy      = "true"
  retention_in_days = 7
}