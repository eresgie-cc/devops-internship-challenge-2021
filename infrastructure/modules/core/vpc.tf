resource "aws_vpc" "internship" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "internship-cc"
  }
}

resource "aws_internet_gateway" "gw_public" {
  vpc_id = aws_vpc.internship.id

  tags = {
    Name = "gw_public"
  }
}
