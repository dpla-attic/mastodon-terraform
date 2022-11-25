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

resource "aws_security_group_rule" "web_inbound_alb" {
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
      values = [ var.local_domain ]
    }
  }
}

resource "aws_ecs_cluster" "fargate_cluster" {
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

# resource "aws_ecs_task_definition" "task_definition" {
#   family                   = local.project_prefix
#   container_definitions    = local.container_def
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   execution_role_arn       = data.terraform_remote_state.ecs_security.outputs.ecs_task_execution_role.arn
#   task_role_arn            = data.terraform_remote_state.ecs_security.outputs.ecs_tasks_execution_role.arn
#   cpu                      = local.fargate_task_cpu
#   memory                   = local.fargate_task_memory

#   tags = merge(
#     local.common_tags, {
#       "Name" = "${local.project_prefix}-task_definition"
#   })
# }

# resource "aws_ecs_service" "fargate_service" {
#   name                               = local.project_prefix
#   cluster                            = aws_ecs_cluster.fargate_cluster.id
#   task_definition                    = aws_ecs_task_definition.task_definition.arn
#   desired_count                      = 2
#   deployment_maximum_percent         = 200
#   deployment_minimum_healthy_percent = 50
#   force_new_deployment               = true
#   launch_type                        = "FARGATE"
#   health_check_grace_period_seconds  = 60

#   # ##################################################
#   # TOGGLE THIS FOR CHANGES OUTSIDE OF CODE DEPLOY
#   # 
#   # FIXME --  this should be conditional on an 
#   #           env variable 
#   # ##################################################
#   deployment_controller {
#     type = "CODE_DEPLOY"
#   }

#   network_configuration {
#     subnets          = [local.subnet_a.id, local.subnet_b.id, local.subnet_c.id]
#     assign_public_ip = true
#     security_groups  = [aws_security_group.service_sg.id]
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.this.0.arn
#     container_name   = "${local.project_prefix}-container"
#     container_port   = local.app_port
#   }

#   depends_on = [
#     local.https_listener
#   ]
# }




# # module "ecs" { #todo
# #   source = "../../modules/services/ecs"

# #   app_port            = local.app_port
# #   bucket              = var.bucket
# #   dynamodb_table      = var.dynamodb_table
# #   ecr_repo_name       = local.ecr_repo_name
# #   fargate_task_memory = local.fargate_task_memory
# #   fargate_task_cpu    = local.fargate_task_cpu
# #   github_repo         = "dpla/api"
# #   health_check_path   = "/health-check"
# #   host_header         = local.host_header
# #   project_name        = local.project_name
# #   project_prefix      = local.project_prefix
# #   region              = var.region

# #   container_def = templatefile(
# #     "fargate-task-def.json.tpl",
# #     {
# #       ecr_repo                 = "283408157088.dkr.ecr.us-east-1.amazonaws.com/${local.ecr_repo_name}"
# #       ecr_tag                  = local.ecr_tag
# #       app_port                 = local.app_port
# #       aws_region               = local.region
# #       project_name             = local.project_prefix
# #       log_group_name           = "/ecs/${local.project_prefix}"
# #       fargate_container_cpu    = local.fargate_container_cpu
# #       fargate_container_memory = local.fargate_container_memory

# #       # Mastodon specific ENV variables for task definition
# #       local_domain             = var.local_domain
# #       redis_host               = var.redis_host
# #       redis_port               = var.redis_port
# #       db_host                  = var.db_host
# #       db_user                  = var.db_user
# #       db_name                  = var.db_name
# #       db_pass                  = var.db_pass
# #       db_port                  = var.db_port
# #       es_enabled               = var.es_enabled
# #       es_host                  = var.es_host
# #       es_port                  = var.es_port
# #       es_user                  = var.es_user
# #       es_pass                  = var.es_pass
# #       secret_key_base          = var.secret_key_base
# #       otp_secret               = var.otp_secret
# #       vapid_private_key        = var.vapid_private_key
# #       vapid_public_key         = var.vapid_public_key
# #       smtp_server              = var.smtp_server
# #       smtp_port                = var.smtp_port
# #       smtp_login               = var.smtp_login
# #       smtp_password            = var.smtp_password
# #       smtp_from_address        = var.smtp_from_address
# #       s3_enabled               = var.s3_enabled
# #       s3_bucket                = var.s3_bucket
# #       s3_alias_host            = var.s3_alias_host
# #       ip_retention_period      = var.ip_retention_period
# #       session_retention_period = var.session_retention_period
# #   })
# # }
