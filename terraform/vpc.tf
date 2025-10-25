resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.environment}-igw" }
}

# Public subnets
resource "aws_subnet" "public" {
  for_each = toset(var.public_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  map_public_ip_on_launch = true
  availability_zone = element(data.aws_availability_zones.available.names, index(var.public_subnets, each.value))
  tags = { Name = "${var.environment}-public-${each.key}" }
}

# Private subnets
resource "aws_subnet" "private" {
  for_each = toset(var.private_subnets)
  vpc_id     = aws_vpc.this.id
  cidr_block = each.value
  availability_zone = element(data.aws_availability_zones.available.names, index(var.private_subnets, each.value))
  tags = { Name = "${var.environment}-private-${each.key}" }
}

# Route tables, routes and NAT (simple pattern: one NAT Gateway in one AZ)
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id = values(aws_subnet.public)[0].id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

data "aws_availability_zones" "available" {}