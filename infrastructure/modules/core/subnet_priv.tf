resource "aws_subnet" "private" {
  for_each   = toset(var.private_cidr)
  vpc_id     = aws_vpc.internship.id
  cidr_block = each.key
  availability_zone = 
  map_public_ip_on_launch = false

  tags = {
    Name = format("private%02d", index(var.private_cidr, each.key) + 1)
  }
}
