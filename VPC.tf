terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.32.1"
    }
  }
  backend "s3" {
    bucket = "smori-s3bucket"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
  default_tags {
    tags = var.default_tags
  }
}

#create VPC: CIDR 10.0.0.0/16
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames = true
  enable_dns_support = true
tags = {
    "Name" = "smVPC"
 }
}

#Public Subnet 10.0.0.0/24
resource "aws_subnet" "public" {
    count = var.Public_subnet_count
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
    ipv6_cidr_block = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index)
    map_public_ip_on_launch = true
    tags = {
        "Name" = "${var.default_tags.env}-Public-Subnet-${data.aws_availability_zones.availability_zone.names[count.index]}"
    }
    availability_zone = data.aws_availability_zones.availability_zone.names[count.index]
}

#Private Subnet 10.0.0.0/24
resource "aws_subnet" "private" {
    count = 2
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + var.Public_subnet_count)
    tags = {
        "Name" = "${var.default_tags.env}-Private-Subnet-${data.aws_availability_zones.availability_zone.names[count.index]}"
    }
    availability_zone = data.aws_availability_zones.availability_zone.names[count.index]
}

#IGW
resource "aws_internet_gateway" "main_igw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "${var.default_tags.env}-igw"
    
    }
}


#Public RT
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
      Name = "${var.default_tags.env}-Public-RT"
  }
}

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main_igw.id
}

resource "aws_route_table_association" "public_routev6" {
  count = var.Public_subnet_count
  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}
#Private RT

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
      "Name" = "${var.default_tags.env}-Private-RT"
  }
}

resource "aws_route" "private_route" {
  route_table_id = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main_nat.id 
  }

resource "aws_route_table_association" "public_rt_association" {
  count = var.Private_subnet_count
  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}

# EIP
resource "aws_eip" "nat_EIP" {
  domain = "vpc"
}

#NAT
resource "aws_nat_gateway" "main_nat" {
  allocation_id = aws_eip.nat_EIP.id
  subnet_id = aws_subnet.public.0.id
  tags = {
    "Name" = "${var.default_tags.env}-ngw"
  }
}