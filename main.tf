# Configure AWS as cloud provider
provider "aws" {
	region = var.aws-region
}

# # Create a VPC
# resource "aws_vpc" "my_vpc" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = "chiedozie-terraform-vpc"
#   }
# }

# resource "aws_subnet" "public_subnet" {
#   vpc_id                  = aws_vpc.my_vpc.id
#   cidr_block              = "10.0.1.0/24"
#   availability_zone       = "${var.aws-region}a"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "chiedozie-terraform-public-subnet"
#   }
# }

# resource "aws_subnet" "private_subnet" {
#   vpc_id            = aws_vpc.my_vpc.id
#   cidr_block        = "10.0.2.0/24"
#   availability_zone = "${var.aws-region}a"

#   tags = {
#     Name = "chiedozie-terraform-private-subnet"
#   }
# }

# resource "aws_internet_gateway" "my_igw" {
#   vpc_id = aws_vpc.my_vpc.id

#   tags = {
#     Name = "chiedozie-terraform-igw"
#   }
# }

# resource "aws_route_table" "public_route_table" {
#   vpc_id = aws_vpc.my_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.my_igw.id
#   }

#   tags = {
#     Name = "chiedozie-terraform-public-route-table"
#   }
# }

# resource "aws_route_table_association" "public_rta" {
#   subnet_id      = aws_subnet.public_subnet.id
#   route_table_id = aws_route_table.public_route_table.id
# }

# resource "aws_network_acl" "my_nacl" {
#   vpc_id = aws_vpc.my_vpc.id

#   egress {
#     protocol   = "-1"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }

#   ingress {
#     protocol   = "-1"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }

#   tags = {
#     Name = "chiedozie-terraform-nacl"
#   }
# }

# resource "aws_security_group" "my_sg" {
#   vpc_id = aws_vpc.my_vpc.id

#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "chiedozie-terraform-sg"
#   }
# }


# Deploy Virtual Private Cloud (VPC)
resource "aws_vpc" "vpc" {
	cidr_block       = var.cidr-vpc
	instance_tenancy = "default"

	tags = {
		Name = "tech254-chiedozie-vpc"
	}
}

# Deploy Internet Gateway and attach to VPC
resource "aws_internet_gateway" "ig" {
	vpc_id = var.vpc-id

	tags = {
		Name = "tech254-chiedozie-igw-tf"
	}
}

# Deploy Public Subnet
resource "aws_subnet" "public_subnet" {
        vpc_id                  = var.vpc-id
 	cidr_block              = var.cidr-public-subnet
 	availability_zone       = "eu-west-1b"
 	map_public_ip_on_launch = true

 	tags = {
 		Name = "tf-chiedozie-public-subnet"
 	}
 }

# Deploy Private Subnet
resource "aws_subnet" "private_subnet" {
 	vpc_id                  = var.vpc-id
 	cidr_block              = var.cidr-private-subnet
 	availability_zone       = "eu-west-1c"
 	map_public_ip_on_launch = false

 	tags = {
 		Name = "tf-chiedozie-private-subnet"
 	}
 }

# Deploy Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
 	vpc_id = var.vpc-id

 	route {
 		cidr_block = var.cidr-public-subnet
 		gateway_id = var.igw-id
 	}
 	tags = {
 		Name = "tf-public-rt"
 	}
 }

# Private Subnet will be routed private by default

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
# Deploy Public Subnet Security Group
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

# Deploy Private Subnet Security Group
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

# Deploy EC2 Instance for Web Application in Public Subnet
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

# Deploy EC2 Instance for Database in Private Subnet
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
