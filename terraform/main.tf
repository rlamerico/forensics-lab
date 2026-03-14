terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "forensics" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "forensics-lab-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.forensics.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "forensics-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "forensics" {
  vpc_id = aws_vpc.forensics.id

  tags = {
    Name = "forensics-igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.forensics.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.forensics.id
  }

  tags = {
    Name = "forensics-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "forensics" {
  name        = "forensics-sg"
  description = "Security group for forensics lab"
  vpc_id      = aws_vpc.forensics.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "forensics-sg"
  }
}

# SSH Key Pair
resource "tls_private_key" "forensics" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "forensics" {
  key_name   = "forensics-lab-key"
  public_key = tls_private_key.forensics.public_key_openssh
}

# Save private key locally
resource "local_file" "private_key" {
  filename          = "${path.module}/keys/globomantics.pem"
  content           = tls_private_key.forensics.private_key_pem
  file_permission   = "0600"
  directory_permission = "0700"
}

# Get latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# EC2 Instance
resource "aws_instance" "forensics_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.forensics.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.forensics.id]

  associate_public_ip_address = true

  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name = "forensics-compromised-server"
  }

  depends_on = [
    aws_internet_gateway.forensics
  ]
}

# Outputs
output "server_ip" {
  description = "Public IP of the forensics server"
  value       = aws_instance.forensics_server.public_ip
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i ${abspath(local_file.private_key.filename)} ubuntu@${aws_instance.forensics_server.public_ip}"
}
