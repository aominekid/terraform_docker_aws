resource "aws_subnet" "docker_subnet" {
  vpc_id            = aws_vpc.vpc_docker.id
  cidr_block        = "10.0.0.0/28"
  availability_zone = "us-west-2a"
  tags = {
    Name = "docker-subnet"
  }
}

resource "aws_route_table_association" "rta_docker" {
  subnet_id      = aws_subnet.docker_subnet.id
  route_table_id = aws_route_table.rt_docker.id
}
