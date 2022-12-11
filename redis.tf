resource "aws_elasticache_replication_group" "mastodon-redis-cluster" {
  engine                     = "redis"
  engine_version             = "7.0"
  replication_group_id       = "mastodon-redis-cluster"
  description                = "Mastodon Redis"
  node_type                  = "cache.m6g.large"
  port                       = 6379
  parameter_group_name       = "default.redis7.cluster.on"
  automatic_failover_enabled = true
  auto_minor_version_upgrade = true
  num_node_groups            = 1
  replicas_per_node_group    = 1
  maintenance_window         = "sun:00:00-sun:02:00"
  security_group_ids         = [aws_security_group.mastodon_redis_sg.id]
  snapshot_retention_limit   = 7
  snapshot_window            = "02:00-04:00"
  subnet_group_name          = aws_elasticache_subnet_group.default.name
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.mastodon_log_group.id
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }
}

resource "aws_security_group" "mastodon_redis_sg" {
  name        = "mastodon-redis-sg"
  description = "Mastodon Redis"
  vpc_id      = aws_vpc.main.id
}
