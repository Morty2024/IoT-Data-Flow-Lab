terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.0.0-beta2"
    }
  }

  cloud { 
    
    organization = "The_Giving_Circuits" 

    workspaces { 
      name = "IoT_Data_Flow_Lab" 
    } 
  } 

}

# Aws provider
provider "aws" {
  region = var.region
}

#VPC

resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc1"
    Owner = var.tag_owner
  }
}

# subnet

resource "aws_subnet" "public_subnet1" {
  vpc_id = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "public_subnet1"
    Owner = var.tag_owner
  }
}

#igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "igw"
    Owner = var.tag_owner
  }
}
# route table and association
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "0.0.0"
  }
  tags = {
    Name = "rt1"
    Owner = var.tag_owner
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.rt1.id
}

# ami data block and instance
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "mqtt_client" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet1.id
  associate_public_ip_address = true

  # user_data = <<-EOF
  #             #!/bin/bash
  #             apt-get update
  #             apt-get install -y python3 python3-pip


  #             EOF

  tags = {
    Name = "mqtt_client"
  }
}