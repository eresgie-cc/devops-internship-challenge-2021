resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.internship.id
  cidr_block = var.public_cidr

  map_public_ip_on_launch = true

  tags = {
    Name = "public"
  }
}
