resource "aws_route_table" "private" {
  vpc_id = aws_vpc.internship.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = null
      carrier_gateway_id         = null
      destination_prefix_list_id = null
      egress_only_gateway_id     = null
      instance_id                = aws_instance.nat.id
      ipv6_cidr_block            = null
      local_gateway_id           = null
      nat_gateway_id             = null
      network_interface_id       = null
      transit_gateway_id         = null
      vpc_endpoint_id            = null
      vpc_peering_connection_id  = null
    }
  ]

  tags = {
    Name = "private_rt"
  }

  depends_on = [
    aws_instance.nat,
  ]
}

resource "aws_route_table_association" "a_private" {
  for_each       = toset(var.private_cidr)
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.internship.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.gw_public.id
      carrier_gateway_id         = null
      destination_prefix_list_id = null
      egress_only_gateway_id     = null
      instance_id                = null
      ipv6_cidr_block            = null
      local_gateway_id           = null
      nat_gateway_id             = null
      network_interface_id       = null
      transit_gateway_id         = null
      vpc_endpoint_id            = null
      vpc_peering_connection_id  = null
    }
  ]

  tags = {
    Name = "private_rt"
  }
  depends_on = [aws_internet_gateway.gw_public]
}

resource "aws_route_table_association" "a_public" {
  for_each       = toset(var.public_cidr)
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}
