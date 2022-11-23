resource "aws_db_instance" "mastodon_db" {
  allocated_storage           = var.db_storage
  allow_major_version_upgrade = false
  apply_immediately           = true
  auto_minor_version_upgrade  = true
  max_allocated_storage       = 500
  multi_az                    = true
  backup_retention_period     = var.db_backup_retention_period
  backup_window               = var.db_backup_window
  db_name                     = var.db_name
  maintenance_window          = var.db_maintenance_window
  db_subnet_group_name        = aws_db_subnet_group.default.id
  deletion_protection         = false
  skip_final_snapshot         = true
  identifier                  = "mastodon-db"
  storage_type                = "gp2"
  engine                      = "postgres"
  engine_version              = "14.5"
  instance_class              = var.db_instance_class
  username                    = var.db_username
  password                    = var.db_password
  port                        = 5432
  publicly_accessible         = false
  vpc_security_group_ids      = [aws_security_group.mastodon_db_sg.id]
}
resource "aws_db_subnet_group" "default" {
  name        = "main_subnet_group"
  description = "Main group of subnets"
  subnet_ids  = [aws_default_subnet.subnet_a.id, aws_default_subnet.subnet_b.id]
}

resource "aws_security_group" "mastodon_db_sg" {
  name        = "mastodon-db-sg"
  description = "Mastodon Database"
  vpc_id      = aws_default_vpc.vpc.id
}

resource "aws_security_group_rule" "inbound_postgres" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.mastodon_db_sg.id
  source_security_group_id = aws_security_group.mastodon_web_sg.id
}

