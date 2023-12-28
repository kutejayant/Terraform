terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws"{
  region = "us-east-1"
}


resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"   
}

 variable "public_subnets_cidr_block" {
    default = ["10.0.5.0/24", "10.0.6.0/24"]
}

  variable "private_subnets_cidr_block" {
    default = ["10.0.7.0/24", "10.0.8.0/24"]
}
resource "aws_subnet" "public_subnets" {
  count     = length( var.public_subnets_cidr_block)
  vpc_id    = aws_vpc.my_vpc.id
  cidr_block = var.public_subnets_cidr_block[count.index]
   tags = {
    "Name" = "public_subnet ${count.index + 1}"
  }
}
resource "aws_subnet" "private_subnets" {
  count     = length( var.private_subnets_cidr_block)
  vpc_id    = aws_vpc.my_vpc.id
  cidr_block= element (var.private_subnets_cidr_block, count.index)
 # cidr_block = var.private_subnets_cidr_block[count.index]
    tags = {
    "Name" = "private_subnet ${count.index + 1}"
  }
}
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id  
}

resource "aws_route_table" "public_rt" {
 # count  = length(aws_subnet.public_subnets)
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
    tags = {
    "Name" = "public_rt 1st"
  }
}
resource "aws_route_table" "private_rt" {
  #count  = length(aws_subnet.private_subnets)
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
   nat_gateway_id = aws_nat_gateway.my_ngw.id
  }
   tags = {
    "Name" = "private_rt 2rt"
  }
}
resource "aws_eip" "my_eip" {
  domain =  "vpc"
}
 resource "aws_nat_gateway" "my_ngw" {
  #count = length(aws_subnet.public_subnets)
  allocation_id = aws_eip.my_eip.id
 # subnet_id     = element (aws_subnet.public_subnets[*].id ,0 )
 subnet_id = aws_subnet.public_subnets[0].id
  
  tags = {
    "Name" = "my_ngw"
  }
}
resource "aws_route_table_association" "private_associations" {
  count         = length( var.private_subnets_cidr_block)
  subnet_id     = element (aws_subnet.private_subnets[*].id, count.index)
  route_table_id =  aws_route_table.private_rt.id
}

resource "aws_route_table_association" "public_associations" {
  count         = length( var.public_subnets_cidr_block)
  subnet_id     = element (aws_subnet.public_subnets[*].id,count.index )
  route_table_id =  aws_route_table.public_rt.id 
}
 
