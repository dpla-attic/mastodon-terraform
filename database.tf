resource "aws_rds_cluster" "mastodon_db" {
  cluster_identifier              = "mastodon-db"
  engine                          = "aurora-postgresql"
  engine_mode                     = "provisioned"
  engine_version                  = "14.5"
  database_name                   = var.db_name
  master_username                 = var.db_username
  master_password                 = var.db_password
  port                            = 5432
  final_snapshot_identifier       = "mastodon-db"
  backup_retention_period         = var.db_backup_retention_period
  preferred_backup_window         = var.db_backup_window
  preferred_maintenance_window    = var.db_maintenance_window
  db_subnet_group_name            = aws_db_subnet_group.default.id
  enabled_cloudwatch_logs_exports = ["postgresql"]
  vpc_security_group_ids          = [aws_security_group.mastodon_db_sg.id]

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

resource "aws_security_group" "mastodon_db_sg" {
  name        = "mastodon-db-sg"
  description = "Mastodon Database"
  vpc_id      = aws_default_vpc.vpc.id
}