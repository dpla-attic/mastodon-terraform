resource "aws_default_vpc" "vpc" {
}

data "aws_region" "current" {

}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_default_subnet" "subnet_a" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "subnet_b" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_default_subnet" "subnet_c" {
  availability_zone = data.aws_availability_zones.available.names[2]
}

resource "aws_db_subnet_group" "default" {
  name        = "main_subnet_group"
  description = "Main group of subnets"
  subnet_ids = [
    aws_default_subnet.subnet_a.id,
    aws_default_subnet.subnet_b.id,
    aws_default_subnet.subnet_c.id
  ]
}

resource "aws_elasticache_subnet_group" "default" {
  name = "main-subnet-group"
  subnet_ids = [
    aws_default_subnet.subnet_a.id,
    aws_default_subnet.subnet_b.id,
    aws_default_subnet.subnet_c.id
  ]
}
