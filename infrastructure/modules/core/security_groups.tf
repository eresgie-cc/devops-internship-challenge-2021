resource "aws_security_group" "alb" {
  name        = "alb"
  description = "Allow HTTP inbound from internet"
  vpc_id      = aws_vpc.internship.id

  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Any"
      from_port        = 80
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      protocol         = "tcp"
      security_groups  = null
      self             = false
      to_port          = 80
    }
  ]

  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "All"
      from_port        = 0
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      protocol         = "-1"
      security_groups  = null
      self             = false
      to_port          = 0
    }
  ]

  tags = {
    Name = "nat"
  }
}

resource "aws_security_group" "private" {
  name        = "private"
  description = "Allow between private subnets and to Bastionb/NAT/LB instances"
  vpc_id      = aws_vpc.internship.id

  ingress = [
    {
      cidr_blocks      = var.public_cidr
      description      = "HTTP from public"
      from_port        = 80
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      protocol         = "tcp"
      security_groups  = null
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks      = ["${var.bastion_ip}/32"]
      description      = "SSH from bastion"
      from_port        = 22
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      protocol         = "tcp"
      security_groups  = null
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks      = ["${var.bastion_ip}/32"]
      description      = "Kubectl from bastion"
      from_port        = 16443
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      protocol         = "tcp"
      security_groups  = null
      self             = false
      to_port          = 16443
    },
    {
      cidr_blocks      = var.private_cidr
      description      = "CIDRs for private subnets"
      from_port        = 0
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      protocol         = "-1"
      security_groups  = null
      self             = false
      to_port          = 0
    },
  ]

  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "All"
      from_port        = 0
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      protocol         = "-1"
      security_groups  = null
      self             = false
      to_port          = 0
    }
  ]

  tags = {
    Name = "private"
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allow only specific IP for ingress SSH"
  vpc_id      = aws_vpc.internship.id

  ingress = [
    {
      cidr_blocks      = ["${var.ip_to_bastion}/32"]
      description      = "IP of allowed instance"
      from_port        = 22
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      protocol         = "tcp"
      security_groups  = null
      self             = false
      to_port          = 22
    }
  ]

  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "All"
      from_port        = 0
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      protocol         = "-1"
      security_groups  = null
      self             = false
      to_port          = 0
    }
  ]

  tags = {
    Name = "bastion"
  }
}

resource "aws_security_group" "nat" {
  name        = "nat"
  description = "Allow any inbound to NAT from private"
  vpc_id      = aws_vpc.internship.id

  ingress = [
    {
      cidr_blocks      = var.private_cidr
      description      = "CIDRs for private subnets"
      from_port        = 0
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      protocol         = "-1"
      security_groups  = null
      self             = false
      to_port          = 0
    }
  ]

  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "All"
      from_port        = 0
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      protocol         = "-1"
      security_groups  = null
      self             = false
      to_port          = 0
    }
  ]

  tags = {
    Name = "nat"
  }
}
