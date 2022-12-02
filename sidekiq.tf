resource "aws_security_group" "mastodon_sidekiq_sg" {
  name        = "mastodon-sidekiq-sg"
  description = "Mastodon Sidekiq"
  vpc_id      = aws_default_vpc.vpc.id
}

resource "aws_security_group_rule" "sidekiq_inbound_redis" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mastodon_redis_sg.id
  source_security_group_id = aws_security_group.mastodon_sidekiq_sg.id
}

resource "aws_security_group_rule" "sidekiq_inbound_postgres" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mastodon_db_sg.id
  source_security_group_id = aws_security_group.mastodon_sidekiq_sg.id
}

