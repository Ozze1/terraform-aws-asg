terraform {
  required_version = "~> 1.7.0"
}

provider "aws" {
  region = var.region
}

data "aws_vpc" "main" {
  default = true
}

data "aws_subnets" "main" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_ami" "linux2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami*gp2"]
  }
}

module "asg" {
  source       = "../../"
  name_prefix  = var.name_prefix
  vpc_id       = data.aws_vpc.main.id
  subnet_ids   = data.aws_subnets.main.ids
  instance_ami = data.aws_ami.linux2.id

  tags = {
    terraform   = "True"
    environment = "dev"
  }
}
