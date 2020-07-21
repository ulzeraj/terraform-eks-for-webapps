#
# VPC Resources
#  * VPC
#  * Public subnet
#  * Internet gateway
#  * Public route table
#  * Private subnet
#  * Private nat gateway
#  * Private route table
#

variable "az" {}
variable "cluster-name" {}

resource "aws_vpc" "kubernetes" {
  cidr_block = "10.0.0.0/16"

  tags = map(
    "Name", "${var.cluster-name}",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "kubernetes-public" {
  count = 2

  availability_zone       = var.az.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  vpc_id                  = aws_vpc.kubernetes.id
  map_public_ip_on_launch = "true"

  tags = map(
    "Name", "${var.cluster-name}-public",
    "kubernetes.io/elb", "1",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "kubernetes-public" {
  vpc_id = aws_vpc.kubernetes.id

  tags = {
    Name = "${var.cluster-name}-public"
  }
}

resource "aws_route_table" "kubernetes-public" {
  vpc_id = aws_vpc.kubernetes.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kubernetes-public.id
  }
  tags = {
    Name = "${var.cluster-name}-public"
  }
}

resource "aws_route_table_association" "kubernetes-public" {
  count = 2
  subnet_id      = aws_subnet.kubernetes-public.*.id[count.index]
  route_table_id = aws_route_table.kubernetes-public.id
}


resource "aws_eip" "kubernetes-egress" {
  count = 2
  vpc = true
  tags = {
    Name = "${var.cluster-name}-egress"
  }
}

resource "aws_nat_gateway" "kubernetes-nat" {
  count = 2
  allocation_id = aws_eip.kubernetes-egress.*.id[count.index]
  subnet_id = aws_subnet.kubernetes-public.*.id[count.index]
  depends_on = [
    aws_internet_gateway.kubernetes-public
  ]
  tags = {
    Name = "${var.cluster-name}-natgw"
  }
}

resource "aws_subnet" "kubernetes-private" {
  count = 2
  availability_zone       = var.az.names[count.index]
  cidr_block              = "10.0.${count.index + 2}.0/24"
  vpc_id                  = aws_vpc.kubernetes.id
  map_public_ip_on_launch = "false"

  tags = map(
    "Name", "${var.cluster-name}-private",
    "kubernetes.io/internal-elb", "1",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_route_table" "kubernetes-private" {
  count = 2
  vpc_id = aws_vpc.kubernetes.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.kubernetes-nat.*.id[count.index]
  }
  tags = {
    Name = "${var.cluster-name}-private"
  }
}

resource "aws_route_table_association" "kubernetes-private" {
  count = 2
  subnet_id      = aws_subnet.kubernetes-private.*.id[count.index]
  route_table_id = aws_route_table.kubernetes-private.*.id[count.index]
}


output "vpc_id" {
  value = aws_vpc.kubernetes.id
}

output "public_subnet_ids" {
  value = aws_subnet.kubernetes-public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.kubernetes-private[*].id
}
