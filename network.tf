resource "aws_vpc" "main" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_flow_log" "flow_log" {
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.mastodon_log_group.arn
  traffic_type    = "REJECT"
  vpc_id          = aws_vpc.main.id
}

resource "aws_iam_role" "flow_log" {
  name = "flow-log"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "flow_log" {
  name = "flow_log"
  role = aws_iam_role.flow_log.id

  policy = jsonencode({
    Statement = [
      {
        Action = [
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow",
        Resource = "${aws_flow_log.flow_log.arn}"
      }
    ]
  })
}

data "aws_region" "current" {

}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.0.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_route_table_association" "subnet_a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.main.id
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "10.10.1.0/24"
}

resource "aws_route_table_association" "subnet_b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.main.id
}

resource "aws_subnet" "subnet_c" {
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[2]
  cidr_block        = "10.10.2.0/24"
}

resource "aws_route_table_association" "subnet_c" {
  subnet_id      = aws_subnet.subnet_c.id
  route_table_id = aws_route_table.main.id
}

locals {
  subnet_ids = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id,
    aws_subnet.subnet_c.id
  ]
}

resource "aws_db_subnet_group" "default" {
  name        = "main_subnet_group"
  description = "Main group of subnets"
  subnet_ids = local.subnet_ids
}

resource "aws_elasticache_subnet_group" "default" {
  name = "main-subnet-group"
  subnet_ids = local.subnet_ids
}
