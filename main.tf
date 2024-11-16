resource "aws_security_group" "docker_sg" {
  vpc_id = aws_vpc.vpc_docker.id
  tags = {
    Name = "docker-sg"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9002
    to_port     = 9002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "docker_instance" {
  ami           = "ami-04907f297c18de05a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.docker_subnet.id
  security_groups = [aws_security_group.docker_sg.name]
  key_name      = "vockey"

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
