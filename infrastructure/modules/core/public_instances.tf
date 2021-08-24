locals {
  public_subnets_ids = tolist([
    for subnet in aws_subnet.public : subnet.id
  ])
}
// NAT
data "aws_ami" "nat_ami" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["vnscubed*-aws-marketplace-nate-free_hvm-*"]
  }
}

resource "aws_instance" "nat" {
  ami                         = data.aws_ami.nat_ami.id
  instance_type               = "t3.nano"
  subnet_id                   = local.public_subnets_ids[0]
  security_groups             = [aws_security_group.nat.id]
  associate_public_ip_address = true
  source_dest_check           = false

  tags = {
    Name = "nat"
  }

  depends_on = [aws_security_group.nat]

}

// bastion
// Somehow I cannot setup Session Manager from SSM, 
// probably due to some kind of issue with IAM role for instance profile.
// So thats why I've chosen bastion host

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

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.nano"
  subnet_id                   = local.public_subnets_ids[0]
  security_groups             = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  private_ip                  = var.bastion_ip
  key_name                    = var.bastion_key_name

  user_data = <<-EOF
              #!/bin/bash
              sleep 300
              # Install kubectl
              # Only need to manually get config for connection
              sudo apt-get update
              sudo apt-get install -y apt-transport-https ca-certificates curl
              sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
              echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
              sudo apt-get update
              sudo apt-get install -y kubectl
	          EOF

  tags = {
    Name = "bastion"
  }

  depends_on = [aws_security_group.bastion]
}
