provider "aws" {
  region = "${var.aws_region}"
  shared_credentials_file = "~/.aws/credentials"
}

resource "aws_vpc" "tfVPC" {
  cidr_block = "${var.vpc_cidr}"

  tags = {
    Name = "tfVPC"
    Description = "Provisioned via Terraform"
  }
}

resource "aws_internet_gateway" "tfIGW" {
  vpc_id = "${aws_vpc.tfVPC.id}"

  tags = {
    Name = "tfIGW"
  }
}

resource "aws_eip" "tfEIP" {
  count = "${length(var.public_subnets)}"
  depends_on = ["aws_internet_gateway.tfIGW"]

  tags = {
    Name = "NAT IP # ${count.index + 1}"
  }
}

resource "aws_subnet" "tfPubSubs" {
  vpc_id = "${aws_vpc.tfVPC.id}"
  count = "${length(var.public_subnets)}"
  cidr_block = "${element(var.public_subnets, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet # ${count.index + 1}"
  }
}

resource "aws_subnet" "tfPrivSubs" {
  vpc_id = "${aws_vpc.tfVPC.id}"
  count = "${length(var.private_subnets)}"  
  cidr_block = "${element(var.private_subnets, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet # ${count.index + 1}"
  }
}

resource "aws_nat_gateway" "tfNAT" {
  count = "${length(var.public_subnets)}"
  allocation_id = "${element(aws_eip.tfEIP.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.tfPubSubs.*.id, count.index)}"

  tags = {
    Name = "NAT Gateway # ${count.index + 1}"
  }
}

resource "aws_route_table" "tfRPriv" {
  count = "${length(var.private_subnets)}"
  vpc_id = "${aws_vpc.tfVPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.tfNAT.*.id, count.index)}"
  }

  tags = {
    Name = "TF-Priv-NAT-Route-Table # ${count.index}"
  }
}

resource "aws_route_table_association" "tfPrivate" {
  count = "${length(aws_route_table.tfRPriv.*.id)}"
  subnet_id      = "${element(aws_subnet.tfPrivSubs.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.tfRPriv.*.id, count.index)}"
}

resource "aws_default_route_table" "tfUpdate" {
  default_route_table_id = "${aws_vpc.tfVPC.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tfIGW.id}"
  }

  tags = {
    Name = "TF Main VPC"
  }
}
