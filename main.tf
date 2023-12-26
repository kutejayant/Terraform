terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = 192.168.0.0/16
}
 
resource "aws_subnet" "my_vpc" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.0.1/17"
} 

resource "aws_route" "my_rout" {
  
}