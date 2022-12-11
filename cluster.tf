resource "aws_ecs_cluster" "fargate_cluster" {
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  name = "mastodon-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "web_capacity_provider" {
  cluster_name       = aws_ecs_cluster.fargate_cluster.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

data "aws_iam_policy_document" "ecs_task_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

locals {
  redis = aws_elasticache_replication_group.mastodon-redis-cluster
  db    = aws_rds_cluster.mastodon_db
  mastodon_environment_vars = {
    "LOCAL_DOMAIN"             = var.local_domain
    "REDIS_HOST"               = local.redis.configuration_endpoint_address
    "REDIS_PORT"               = local.redis.port
    "DB_HOST"                  = local.db.endpoint
    "DB_USER"                  = local.db.master_username
    "DB_NAME"                  = local.db.database_name
    "DB_PASS"                  = local.db.master_password
    "DB_PORT"                  = local.db.port
    "ES_ENABLED"               = false
    "ES_HOST"                  = ""
    "ES_PORT"                  = ""
    "ES_USER"                  = ""
    "ES_PASS"                  = ""
    "SECRET_KEY_BASE"          = var.secret_key_base
    "OTP_SECRET"               = var.otp_secret
    "VAPID_PRIVATE_KEY"        = var.vapid_private_key
    "VAPID_PUBLIC_KEY"         = var.vapid_public_key
    "SMTP_SERVER"              = "email-smtp.${data.aws_region.current.name}.amazonaws.com"
    "SMTP_PORT"                = 587
    "SMTP_LOGIN"               = aws_iam_access_key.ses_smtp_user_access_key.id
    "SMTP_PASSWORD"            = aws_iam_access_key.ses_smtp_user_access_key.ses_smtp_password_v4
    "SMTP_FROM_ADDRESS"        = "admin@${var.local_domain}"
    "S3_ENABLED"               = false
    "S3_BUCKET"                = ""
    "S3_ALIAS_HOST"            = ""
    "IP_RETENTION_PERIOD"      = var.ip_retention_period
    "SESSION_RETENTION_PERIOD" = var.session_retention_period
  }
}