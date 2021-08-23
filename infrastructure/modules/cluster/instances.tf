data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "node_1" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t3.small"
  subnet_id       = var.private_subnet_id[0]
  security_groups = [var.sg_cluster_id]
  // This time Im using only one key
  // because it will be easier to show "internals" of infrastructure
  // In "real-case" scenario there would be different keys for each instance.
  // But in truly real-case scenario I would try to implement Session Manager
  key_name                    = var.node_key_name
  associate_public_ip_address = false

  tags = {
    Name = "node_01"
  }
}

resource "aws_instance" "node_2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  subnet_id                   = var.private_subnet_id[1]
  security_groups             = [var.sg_cluster_id]
  key_name                    = var.node_key_name
  associate_public_ip_address = false

  tags = {
    Name = "node_02"
  }
}

resource "aws_instance" "node_3" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  subnet_id                   = var.private_subnet_id[2]
  security_groups             = [var.sg_cluster_id]
  key_name                    = var.node_key_name
  associate_public_ip_address = false

  tags = {
    Name = "node_03"
  }
}
