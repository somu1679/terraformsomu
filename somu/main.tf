#This Terraform Code Deploys Basic VPC Infra.
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

terraform {
  required_version = ">= 0.14" #Forcing which version of Terraform needs to be used
  required_providers {
    aws = {
      version = ">= 3.0.0" #Forcing which version of plugin needs to be used.
      source = "hashicorp/aws"
    }
  }
}

resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags = {
        Name = "${var.vpc_name}"
	Owner = "SOMASEKHAR"
	environment = "${var.environment}"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
	tags = {
        Name = "${var.IGW_name}"
    }
}

resource "aws_subnet" "subnet1-public" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.public_subnet1_cidr}"
    availability_zone = "ap-south-1a"

    tags = {
        Name = "${var.public_subnet1_name}"
    }
}

resource "aws_subnet" "subnet2-public" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.public_subnet2_cidr}"
    availability_zone = "ap-south-1b"

    tags = {
        Name = "${var.public_subnet2_name}"
    }
}

resource "aws_subnet" "subnet3-public" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.public_subnet3_cidr}"
    availability_zone = "ap-south-1c"

    tags = {
        Name = "${var.public_subnet3_name}"
    }
	
}


resource "aws_route_table" "terraform-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags = {
        Name = "${var.Main_Routing_Table}"
    }
}

resource "aws_route_table_association" "terraform-public" {
    subnet_id = "${aws_subnet.subnet1-public.id}"
    route_table_id = "${aws_route_table.terraform-public.id}"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.default.id}"
}

resource "aws_instance" "web-1" {
     #ami = var.imagename
     ami = "ami-052cef05d01020f1d"
     #ami = "${data.aws_ami.my_ami.id}"
     availability_zone = "ap-south-1a"
     instance_type = "t2.micro"
     key_name = "somu-aws"
     subnet_id = "${aws_subnet.subnet1-public.id}"
     vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
     associate_public_ip_address = true	
     tags = {
         Name = "Server-1"
        #Env = "Prod"
        #Owner = "Sree"
 	#CostCenter = "ABCD"
     }
}

