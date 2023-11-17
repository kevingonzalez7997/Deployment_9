provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "us-east-1"

}

################### VPC #######################
resource "aws_vpc" "d9_vpc" {
  cidr_block = "10.0.0.0/16"
    
    tags = {
    "Name" = "D9VPC"
  }
}

################## IGW #######################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.d9_vpc.id
}

################## NGW #######################
resource "aws_nat_gateway" "ngw" {
  subnet_id     = aws_subnet.public_a.id
  allocation_id = aws_eip.elastic-ip.id
}
################# EIP ########################
resource "aws_eip" "elastic-ip" {
  domain = "vpc"
  
}
############### ROUTE TABLE ################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.d9_vpc.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.d9_vpc.id
}

############# Routes #########################
resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_ngw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}
############ Association #######################
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

############### SUBNETS ####################
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.d9_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "d9_public | us-east-1a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.d9_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "d9_public | us-east-1b"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.d9_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "d9_private | us-east-1a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.d9_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "d9_private | us-east-1b"
  }
}