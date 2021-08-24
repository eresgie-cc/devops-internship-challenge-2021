resource "aws_subnet" "public" {
  for_each                = toset(var.public_cidr)
  vpc_id                  = aws_vpc.internship.id
  cidr_block              = each.key
  availability_zone       = var.av_zones[index(var.public_cidr, each.key)]
  map_public_ip_on_launch = true

  tags = {
    Name = format("public%02d", index(var.public_cidr, each.key) + 1)
  }
}
