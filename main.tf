# Configure AWS as cloud provider
provider "aws" {
	region = var.aws-region
}


# Create Virtual Private Cloud (VPC)
resource "aws_vpc" "vpc" {
	cidr_block       = var.cidr-vpc
	instance_tenancy = "default"

	tags = {
		Name = "tech254-chiedozie-vpc"
	}
}

# Create Internet Gateway and attach to VPC
resource "aws_internet_gateway" "ig" {
	vpc_id = aws_vpc.vpc.id

	tags = {
		Name = "tech254-chiedozie-igw-tf"
	}
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
    vpc_id                  = aws_vpc.vpc.id
 	cidr_block              = var.cidr-public-subnet
 	availability_zone       = "eu-west-1b"
 	map_public_ip_on_launch = true

 	tags = {
 		Name = "tf-chiedozie-public-subnet"
 	}
 }

# Create Private Subnet
resource "aws_subnet" "private_subnet" {
 	vpc_id                  = aws_vpc.vpc.id
 	cidr_block              = var.cidr-private-subnet
 	availability_zone       = "eu-west-1c"
 	map_public_ip_on_launch = false

 	tags = {
 		Name = "tf-chiedozie-private-subnet"
 	}
 }

# Create Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
 	vpc_id = aws_vpc.vpc.id

 	route {
 		cidr_block = var.cidr-public-rt
 		gateway_id = aws_internet_gateway.ig.id
 	}
 	tags = {
 		Name = "tf-public-rt"
 	}
 }

# Private Subnet is routed private by default

# Associate Public Subnet With Route Table
resource "aws_route_table_association" "public_route" {
	subnet_id      = aws_subnet.public_subnet.id
	route_table_id = aws_route_table.public_rt.id
}

# Create NACL
resource "aws_network_acl" "my_nacl" {
  vpc_id = aws_vpc.vpc.id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "chiedozie-terraform-nacl"
  }
}
# Create Public Subnet Security Group
resource "aws_security_group" "public_subnet_sg" {
	name        = "public_subnet_sg"
	description = "Allow Port 80 (HTTP), 22 (SSH), 3000 (NodeJs)"
	vpc_id      = aws_vpc.vpc.id

 	ingress {
        description = "HTTP"
 		from_port   = 80
 		to_port     = 80
 		protocol    = "tcp"
 		cidr_blocks = ["0.0.0.0/0"]
 	}
 	ingress {
	    description = "SSH"
 		from_port   = 22
 		to_port     = 22
 		protocol    = "tcp"
 		cidr_blocks = ["0.0.0.0/0"]
 	}
	ingress {
	    description = "NodeJs"
		from_port   = 3000
		to_port     = 3000
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

# Create Private Subnet Security Group
resource "aws_security_group" "private_subnet_sg" {
	name        = "private_subnet_sg"
	description = "Allow Port 27017 (MongoDB)"
	vpc_id      = aws_vpc.vpc.id

	ingress {
		from_port   = 27017
		to_port     = 27017
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

# Create EC2 Instance for Web Application in Public Subnet
resource "aws_instance" "app_instance" {
	ami                         = var.app-ami-id
	instance_type               = "t2.micro"
	key_name                    = "tech254"
	vpc_security_group_ids      = [aws_security_group.public_subnet_sg.id]
	subnet_id                   = aws_subnet.public_subnet.id
	associate_public_ip_address = true
	tags = {
		Name = "tech254-chiedozie-app-tf"
	}
}

# Create EC2 Instance for Database in Private Subnet
resource "aws_instance" "db_instance" {
	ami                         = var.db-ami-id
	instance_type               = "t2.micro"
	key_name                    = "tech254"
	vpc_security_group_ids      = [aws_security_group.private_subnet_sg.id]
	subnet_id                   = aws_subnet.private_subnet.id
	associate_public_ip_address = false
	tags = {
		Name = "tech254-chiedozie-db-tf"
	}
}
