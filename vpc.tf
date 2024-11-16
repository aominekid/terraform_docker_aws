# VPC erstellen
resource "aws_vpc" "vpc_docker" {
  cidr_block = "10.0.0.0/27"
  tags = {
    Name = "vpc-docker"
  }
}