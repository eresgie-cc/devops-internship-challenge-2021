output "vpc_id" {
  value = aws_vpc.internship.id
}

output "public_id" {
  value = toset([
    for subnet in aws_subnet.public : subnet.id
  ])
}

output "private_subnet_id" {
  value = toset([
    for subnet in aws_subnet.private : subnet.id
  ])
}

output "sg_cluster_id" {
  value = aws_security_group.private.id
}

output "sg_alb_id" {
  value = aws_security_group.alb.id
}
