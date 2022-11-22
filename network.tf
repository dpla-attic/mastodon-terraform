resource "aws_default_vpc" "vpc" {
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
