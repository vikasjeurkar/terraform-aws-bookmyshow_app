terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "ap-south-1"
}

# --------------------------------------------------
# VPC
# --------------------------------------------------

resource "aws_vpc" "myvpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

# --------------------------------------------------
# Subnet 1
# --------------------------------------------------

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

# --------------------------------------------------
# Subnet 2
# --------------------------------------------------

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

# --------------------------------------------------
# Internet Gateway
# --------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "my-igw"
  }
}

# --------------------------------------------------
# Route Table
# --------------------------------------------------

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# --------------------------------------------------
# Route Table Association - Subnet 1
# --------------------------------------------------

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

# --------------------------------------------------
# Route Table Association - Subnet 2
# --------------------------------------------------

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}

# --------------------------------------------------
# ALB Security Group
# --------------------------------------------------

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB-SG"
  }
}

# --------------------------------------------------
# EC2 Security Group
# --------------------------------------------------

resource "aws_security_group" "webSg" {
  name        = "web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.myvpc.id

  # HTTP traffic from ALB only
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # SSH
  # For production, replace 0.0.0.0/0 with your public IP.
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-SG"
  }
}

# --------------------------------------------------
# EC2 Instance 1
# --------------------------------------------------

resource "aws_instance" "webserver1" {
  ami           = "ami-08188a5a4dfdbd573"
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.webSg.id
  ]

  subnet_id = aws_subnet.sub1.id

  user_data = file("userdata.sh")

  tags = {
    Name = "WebServer-1"
  }
}

# --------------------------------------------------
# EC2 Instance 2
# --------------------------------------------------

resource "aws_instance" "webserver2" {
  ami           = "ami-08188a5a4dfdbd573"
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.webSg.id
  ]

  subnet_id = aws_subnet.sub2.id

  user_data = file("userdata1.sh")

  tags = {
    Name = "WebServer-2"
  }
}

# --------------------------------------------------
# Application Load Balancer
# --------------------------------------------------

resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.sub1.id,
    aws_subnet.sub2.id
  ]

  tags = {
    Name = "my-alb"
  }
}

# --------------------------------------------------
# Target Group
# --------------------------------------------------

resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "Web-Target-Group"
  }
}

# --------------------------------------------------
# Target Group Attachment - Web Server 1
# --------------------------------------------------

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

# --------------------------------------------------
# Target Group Attachment - Web Server 2
# --------------------------------------------------

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

# --------------------------------------------------
# ALB Listener
# --------------------------------------------------

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# --------------------------------------------------
# Outputs
# --------------------------------------------------

output "loadbalancerdns" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.myalb.dns_name
}

output "webserver1_public_ip" {
  description = "Public IP of Web Server 1"
  value       = aws_instance.webserver1.public_ip
}

output "webserver2_public_ip" {
  description = "Public IP of Web Server 2"
  value       = aws_instance.webserver2.public_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.myvpc.id
}