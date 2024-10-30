terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-west-2"
  profile = "default"
}

# VPC
resource "aws_vpc" "vivaldi_vpc" {
  cidr_block = "192.168.0.0/24"  # 256 IPs

  tags = {
    Name = "Vivaldi-VPC"
  }
}

# Public Subnet
resource "aws_subnet" "vivaldi_public_subnet" {
  vpc_id            = aws_vpc.vivaldi_vpc.id
  cidr_block        = "192.168.0.0/28"  # 16 IPs
  availability_zone = "us-west-2a"

  tags = {
    Name = "Vivaldi-PublicSubnet"
  }
}

# Private Subnets
resource "aws_subnet" "vivaldi_private_subnet_1" {
  vpc_id            = aws_vpc.vivaldi_vpc.id
  cidr_block        = "192.168.0.16/28"  # 16 IPs
  availability_zone = "us-west-2b"

  tags = {
    Name = "Vivaldi-PrivateSubnet-1"
  }
}

resource "aws_subnet" "vivaldi_private_subnet_2" {
  vpc_id            = aws_vpc.vivaldi_vpc.id
  cidr_block        = "192.168.0.32/28"  # 16 IPs
  availability_zone = "us-west-2c"

  tags = {
    Name = "Vivaldi-PrivateSubnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "vivaldi_ig" {
  vpc_id = aws_vpc.vivaldi_vpc.id

  tags = {
    Name = "Vivaldi-IG"
  }
}

# Public Route Table
resource "aws_route_table" "vivaldi_public_rt" {
  vpc_id = aws_vpc.vivaldi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vivaldi_ig.id
  }

  tags = {
    Name = "Vivaldi-PublicRT"
  }
}

# Route Table Association for Public Subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.vivaldi_public_subnet.id
  route_table_id = aws_route_table.vivaldi_public_rt.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "vivaldi_nat_eip" {
  domain = "vpc" 
}

# NAT Gateway
resource "aws_nat_gateway" "vivaldi_nat" {
  allocation_id = aws_eip.vivaldi_nat_eip.id
  subnet_id    = aws_subnet.vivaldi_public_subnet.id

  tags = {
    Name = "Vivaldi-NAT-Gateway"
  }
}


# Private Route Table
resource "aws_route_table" "vivaldi_private_rt" {
  vpc_id = aws_vpc.vivaldi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.vivaldi_nat.id
  }

  tags = {
    Name = "Vivaldi-PrivateRT"
  }
}

# Route Table Association for Private Subnets
resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.vivaldi_private_subnet_1.id
  route_table_id = aws_route_table.vivaldi_private_rt.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.vivaldi_private_subnet_2.id
  route_table_id = aws_route_table.vivaldi_private_rt.id
}

# Elastic IP for Frontend EC2 Instance
resource "aws_eip" "vivaldi_frontend_eip" {
  instance = aws_instance.vivaldi_frontend.id
  domain = "vpc" 
}

# Jumpbox (Bastion Host) EC2 Instance in Public Subnet
resource "aws_instance" "vivaldi_jumpbox" {
  ami                    = "ami-04dd23e62ed049936"  # Specify an appropriate, secure AMI
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.vivaldi_public_subnet.id
  vpc_security_group_ids = [aws_security_group.vivaldi_jumpbox_sg.id]

  associate_public_ip_address = true
  key_name                    = "vivaldi_key"  # Specify your SSH key here

  tags = {
    Name = "Vivaldi-Jumpbox"
  }
}

# Security Group for Jumpbox
resource "aws_security_group" "vivaldi_jumpbox_sg" {
  vpc_id = aws_vpc.vivaldi_vpc.id
  name   = "vivaldi-jumpbox-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict SSH access to your trusted IP or range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Vivaldi-JumpboxSG"
  }
}


# Frontend Security Group
resource "aws_security_group" "vivaldi_frontend_sg" {
  vpc_id = aws_vpc.vivaldi_vpc.id
  name   = "vivaldi-frontend-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Change this to a specific IP or CIDR block for more security
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Vivaldi-FrontendSG"
  }
}

# Backend Security Group
resource "aws_security_group" "vivaldi_backend_sg" {
  vpc_id = aws_vpc.vivaldi_vpc.id
  name   = "vivaldi-backend-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/24"] # Change this to a specific IP or CIDR block for more security
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/24"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Vivaldi-BackendSG"
  }
}

# Frontend EC2 Instance
resource "aws_instance" "vivaldi_frontend" {
  ami                    = "ami-04dd23e62ed049936"
  instance_type          = "t3.medium"
  associate_public_ip_address = true
  subnet_id              = aws_subnet.vivaldi_public_subnet.id
  vpc_security_group_ids = [aws_security_group.vivaldi_frontend_sg.id]
  

    # User Data for nginx Installation
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y nginx
    sudo systemctl restart nginx
  EOF

  key_name = "vivaldi_key"  # Specify your SSH key here

  tags = {
    Name = "Vivaldi-Frontend"
  }
}

# Associate Elastic IP with the Frontend EC2 Instance
resource "aws_eip_association" "frontend_eip_association" {
  instance_id   = aws_instance.vivaldi_frontend.id
  allocation_id = aws_eip.vivaldi_frontend_eip.id
}

# Backend EC2 Instance
resource "aws_instance" "vivaldi_backend" {
  ami                    = "ami-04dd23e62ed049936"
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.vivaldi_private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.vivaldi_backend_sg.id]

  key_name = "vivaldi_key"  # Specify your SSH key here

  tags = {
    Name = "Vivaldi-Backend"
  }
}

