provider "aws" {
  region  = "eu-west-3"
  profile = "gregbkr"
}

terraform {
  #required_version = "~> 1.1.7"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "gregbkr"
    workspaces {
      name = "eth2-staking-testnet"
    }
  }
}

# Fist get the default VPC and subnet IDs
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# VARS
variable "tag" {
  default = "eth2-staking-testnet"
}
variable "az" {
  default = "eu-west-3a"
}
variable "env" {
  default = "test"
}

# EC2
resource "aws_instance" "instance" {
  ami               = "ami-0c6ebbd55ab05f070" # Ubuntu 20.04 (eu-west-3)
  instance_type     = "t2.large" # t2.large
  availability_zone = var.az
  key_name          = "gregbk1@laptopasus"
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "100" # 1000
    encrypted             = "true"
    delete_on_termination = "true"
  }
  vpc_security_group_ids = [aws_security_group.firewall.id]
  iam_instance_profile   = aws_iam_instance_profile.profile.name
  user_data              = file("cloud-config.yml")

  tags = {
    Name          = var.tag
    "Patch Group" = var.env
  }
  volume_tags = {
    Name          = var.tag
    Snapshot      = "daily"
  }
}

# Elastic IP which will not change if instance get recreated
resource "aws_eip" "eip" {
  instance = aws_instance.instance.id
  vpc      = true
}

# Firewall
resource "aws_security_group" "firewall" {
  name        = var.tag
  description = "Security Group"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh"
  }
  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "eth1"
  }
  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "eth1"
  }
  ingress {
    from_port   = 9001
    to_port     = 9001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "eth2"
  }
  ingress {
    from_port   = 9001
    to_port     = 9001
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "eth2"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# OUTPUTS
output "instance_ip" {
  value = [aws_instance.instance.public_ip]
}
output "elastic_ip" {
  value = [aws_eip.eip.public_ip]
}
