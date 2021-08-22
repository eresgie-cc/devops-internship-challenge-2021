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
  subnet_id                   = aws_subnet.public.id
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
  subnet_id                   = aws_subnet.public.id
  security_groups             = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  private_ip                  = var.bastion_ip
  key_name                    = var.bastion_key_name

  tags = {
    Name = "bastion"
  }

  depends_on = [aws_security_group.bastion]

}
