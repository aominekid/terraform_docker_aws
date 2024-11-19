terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.55.0"
    }
  }
}

# Provider konfigurieren
provider "aws" {
  region = "us-west-2"  # Stelle sicher, dass die Region passt
}

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

# Internet-Gateway erstellen
resource "aws_internet_gateway" "igw_docker" {
  vpc_id = aws_vpc.vpc_docker.id
  tags = {
    Name = "igw-docker"
  }
}

# Route Table erstellen und Route hinzufügen
resource "aws_route_table" "rt_docker" {
  vpc_id = aws_vpc.vpc_docker.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_docker.id
  }

  tags = {
    Name = "docker-route-table"
  }
}

# Route Table mit Subnetz verknüpfen
resource "aws_route_table_association" "rta_docker" {
  subnet_id      = aws_subnet.docker_subnet.id
  route_table_id = aws_route_table.rt_docker.id
}

# Security Group erstellen
resource "aws_security_group" "docker_sg" {
  vpc_id = aws_vpc.vpc_docker.id
  tags = {
    Name = "docker-sg"
  }

  # SSH-Zugriff erlauben
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP-Zugriff erlauben
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom TCP Port 9002 erlauben
  ingress {
    from_port   = 9002
    to_port     = 9002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Alle ausgehenden Verbindungen erlauben
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2-Instanz erstellen
resource "aws_instance" "docker_instance" {
  ami           = "ami-061dd8b45bc7deb3d" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.docker_subnet.id
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  key_name      = "vockey"  # Stelle sicher, dass der Key-Pair existiert

  user_data = <<-EOF
              #!/bin/bash
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo yum install -y docker
              sudo systemctl start docker
              sudo usermod -aG docker ec2-user
              docker pull pengbai/docker-supermario
              docker run -dp 9002:8080 pengbai/docker-supermario
              EOF

  tags = {
    Name = "docker"
  }
}



