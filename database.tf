resource "aws_db_subnet_group" "default" {
  name        = "main_subnet_group"
  description = "Main group of subnets"
  subnet_ids  = local.subnet_ids
}

resource "aws_rds_cluster" "mastodon_db" {
  cluster_identifier              = "mastodon-db"
  engine                          = "aurora-postgresql"
  engine_mode                     = "provisioned"
  engine_version                  = null
  database_name                   = var.db_name
  master_username                 = var.db_username
  master_password                 = var.db_password
  port                            = 5432
  final_snapshot_identifier       = "mastodon-db-final"
  backup_retention_period         = var.db_backup_retention_period
  preferred_backup_window         = var.db_backup_window
  preferred_maintenance_window    = var.db_maintenance_window
  db_subnet_group_name            = aws_db_subnet_group.default.id
  enabled_cloudwatch_logs_exports = ["postgresql"]
  vpc_security_group_ids          = [aws_security_group.mastodon_db_sg.id]
  storage_encrypted               = true
  kms_key_id                      = aws_kms_key.rds_key.arn

  serverlessv2_scaling_configuration {
    max_capacity = 128.0
    min_capacity = 0.5
  }
}

resource "aws_kms_key" "rds_key" {
  description             = "RDS key"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                           = 1
  identifier                      = "mastodon-db-${count.index}"
  instance_class                  = "db.serverless"
  cluster_identifier              = aws_rds_cluster.mastodon_db.id
  engine                          = aws_rds_cluster.mastodon_db.engine
  engine_version                  = aws_rds_cluster.mastodon_db.engine_version
  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.rds_key.arn
}

resource "aws_security_group" "mastodon_db_sg" {
  name        = "mastodon-db-sg"
  description = "Mastodon Database"
  vpc_id      = aws_vpc.main.id
}