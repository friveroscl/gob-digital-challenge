locals {
  az = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
}


resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}


resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name = "${var.prefix}-default-route-table"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}


resource "aws_eip" "nat_eip" {
  count  = 3
  domain = "vpc"

  tags = {
    Name = "${var.prefix}-nat-gw-${count.index + 1}"
  }
}


resource "aws_nat_gateway" "nat_gw" {
  count             = 3
  allocation_id     = aws_eip.nat_eip[count.index].id
  connectivity_type = "public"
  subnet_id         = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.prefix}-nat-gw-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.igw]
}


resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, 4, count.index)
  availability_zone       = local.az[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
  }
}


resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 4, count.index + 3)
  availability_zone = local.az[count.index]

  tags = {
    Name = "${var.prefix}-private-subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.prefix}-public-rt"
  }
}


resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  count  = 3
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name = "${var.prefix}-private-rt"
  }
}


resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
