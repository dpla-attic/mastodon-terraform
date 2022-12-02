resource "aws_security_group" "mastodon_web_sg" {
  name        = "mastodon-web-sg"
  description = "Mastodon Webapp"
  vpc_id      = aws_default_vpc.vpc.id
}

resource "aws_security_group_rule" "web_inbound_redis" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mastodon_redis_sg.id
  source_security_group_id = aws_security_group.mastodon_web_sg.id
}

resource "aws_security_group_rule" "web_inbound_postgres" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mastodon_db_sg.id
  source_security_group_id = aws_security_group.mastodon_web_sg.id
}

resource "aws_security_group_rule" "alb_outbound_web" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mastodon_web_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
  description              = "Allow inbound traffic from the ALB"
}

resource "aws_security_group_rule" "web_outbound_ecr" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "-1"
  to_port           = 0
  from_port         = 0
  security_group_id = aws_security_group.mastodon_web_sg.id
}

resource "aws_lb_target_group" "web_tg" {
  name        = "web-target-group"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_default_vpc.vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "2"
    interval            = "25"
    protocol            = "HTTP"
    matcher             = "200-299,301,302" # FIXME narrow range of acceptable response codes 
    timeout             = "10"
    path                = "/"
    unhealthy_threshold = "5"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "forward_to_tg" {
  listener_arn = aws_lb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  condition {
    host_header {
      values = [var.local_domain]
    }
  }
}

locals {
  redis = aws_elasticache_replication_group.mastodon-redis-cluster
  db    = aws_rds_cluster.mastodon_db
}

#"rails", "s", "-p", "3000"]
resource "aws_ecs_task_definition" "web_task_definition" {
  family = "mastodon-web"
  container_definitions = templatefile(
    "web-task-def.json.tpl",
    {
      local_domain             = var.local_domain
      redis_host               = local.redis.configuration_endpoint_address
      redis_port               = local.redis.port
      db_host                  = local.db.endpoint
      db_user                  = local.db.master_username
      db_name                  = local.db.database_name
      db_pass                  = local.db.master_password
      db_port                  = local.db.port
      es_enabled               = false
      es_host                  = ""
      es_port                  = ""
      es_user                  = ""
      es_pass                  = ""
      secret_key_base          = var.secret_key_base
      otp_secret               = var.otp_secret
      vapid_private_key        = var.vapid_private_key
      vapid_public_key         = var.vapid_public_key
      smtp_port                = 587
      smtp_server              = "email-smtp.${data.aws_region.current.name}.amazonaws.com"
      smtp_login               = aws_iam_access_key.ses_smtp_user_access_key.id
      smtp_password            = aws_iam_access_key.ses_smtp_user_access_key.ses_smtp_password_v4
      smtp_from_address        = "admin@${var.local_domain}"
      s3_enabled               = false
      s3_bucket                = ""
      s3_alias_host            = ""
      ip_retention_period      = var.ip_retention_period
      session_retention_period = var.session_retention_period
      mastodon_version         = var.mastodon_version
      web_memory               = var.web_memory
      web_cpu                  = var.web_cpu
      aws_region               = data.aws_region.current.name
      log_group_name           = aws_cloudwatch_log_group.mastodon_log_group.name
  })
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = var.web_cpu
  memory                   = var.web_memory
}

resource "aws_ecs_service" "fargate_service" {
  name                               = "mastodon-web"
  cluster                            = aws_ecs_cluster.fargate_cluster.id
  task_definition                    = aws_ecs_task_definition.web_task_definition.arn
  desired_count                      = 2
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  force_new_deployment               = true
  launch_type                        = "FARGATE"
  health_check_grace_period_seconds  = 60

  network_configuration {
    subnets = [
      aws_default_subnet.subnet_a.id,
      aws_default_subnet.subnet_b.id,
      aws_default_subnet.subnet_c.id
    ]
    assign_public_ip = true
    security_groups = [
      aws_security_group.mastodon_web_sg.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web_tg.arn
    container_name   = "mastodon-web"
    container_port   = 3000
  }

  depends_on = [
    aws_lb_listener.https
  ]
}
