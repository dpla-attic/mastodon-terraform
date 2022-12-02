# resource "aws_opensearch_domain_policy" "main" {
#   domain_name = "${local.project_prefix}-es"

#   access_policies = <<POLICIES
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "*"
#       },
#       "Action": "es:*",
#       "Resource": "${aws_opensearch_domain.mastodon_search.arn}/*"
#     }
#   ]
# }
# POLICIES
# }

# resource "aws_opensearch_domain" "mastodon_search" {
#   domain_name    = "mastodon-search-es"
#   engine_version = "Elasticsearch_7.10"

#   auto_tune_options {
#     desired_state       = "ENABLED"
#     rollback_on_disable = "NO_ROLLBACK"
#     maintenance_schedule {
#       start_at = var.search_maintenance_schedule
#       duration {
#         value = var.search_maintenance_duration_hours
#         unit  = "HOURS"
#       }
#       cron_expression_for_recurrence = var.search_maintenance_cron
#     }
#   }

#   cluster_config {
#     dedicated_master_enabled = false
#     dedicated_master_type    = ""
#     instance_type            = local.search_instance_type
#     instance_count           = local.search_instance_count
#     warm_enabled             = false
#     zone_awareness_enabled   = true
#     zone_awareness_config {
#       availability_zone_count = 2
#     }
#   }

#   ebs_options {
#     ebs_enabled = true
#     volume_size = local.search_volume_size
#   }

#   encrypt_at_rest {
#     enabled = false
#   }

#   snapshot_options {
#     automated_snapshot_start_hour = 4
#   }

#   vpc_options {
#     subnet_ids         = [aws_default_subnet.subnet_a.id, aws_default_subnet.subnet_b.id]
#     security_group_ids = [aws_security_group.mastodon_search_sg.id]
#   }
# }

# resource "aws_security_group" "mastodon_search_sg" {
#   name        = "mastodon-search-sg"
#   description = "Mastodon Search Cluster"
#   vpc_id      = aws_default_vpc.vpc.id
# }

# resource "aws_security_group_rule" "inbound_search" {
#   type                     = "ingress"
#   from_port                = 443
#   to_port                  = 443
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.mastodon_db_sg.id
#   source_security_group_id = aws_security_group.mastodon_web_sg.id
# }
