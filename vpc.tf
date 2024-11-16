# VPC erstellen
resource "aws_vpc" "vpc_docker" {
  cidr_block = "10.0.0.0/27"
  tags = {
    Name = "vpc-docker"
  }
}

# Subnetz erstellen
resource "aws_subnet" "docker_subnet" {
  vpc_id            = aws_vpc.vpc_docker.id
  cidr_block        = "10.0.0.0/28"
  availability_zone = "us-west-2a"
  tags = {
    Name = "docker-subnet"
  }
}