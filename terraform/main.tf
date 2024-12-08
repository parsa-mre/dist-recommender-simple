provider "aws" {
  region = "us-east-1" # Free tier region
}

# VPC Configuration
resource "aws_vpc" "movie_similarity_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "movie-similarity-vpc"
  }

  # Enable DNS hostnames
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Internet Gateway
resource "aws_internet_gateway" "movie_similarity_igw" {
  vpc_id = aws_vpc.movie_similarity_vpc.id

  tags = {
    Name = "movie-similarity-igw"
  }
}

# Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.movie_similarity_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.movie_similarity_igw.id
  }

  tags = {
    Name = "movie-similarity-public-route-table"
  }
}

# Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.movie_similarity_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "movie-similarity-public-subnet"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Group
resource "aws_security_group" "movie_similarity_sg" {
  name        = "movie-similarity-sg"
  description = "Security group for movie similarity service"
  vpc_id      = aws_vpc.movie_similarity_vpc.id

  # Inbound HTTP traffic
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH for management
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "movie_similarity_instance" {
  ami           = "ami-0c7217cdde317cfec" # Amazon Linux 2 AMI (free tier)
  instance_type = "t2.micro"              # Free tier instance type

  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.movie_similarity_sg.id]
  associate_public_ip_address = true

  user_data = templatefile("../scripts/EC2-setup.sh", {
    INSTANCE_TYPE = "master"
  })
}

# Output the public IP
output "instance_public_ip" {
  value = aws_instance.movie_similarity_instance.public_ip
}

# Output the public DNS
output "instance_public_dns" {
  value = aws_instance.movie_similarity_instance.public_dns
}
