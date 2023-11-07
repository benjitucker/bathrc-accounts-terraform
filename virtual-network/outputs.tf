output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet" {
  value = aws_subnet.public
}

output "private_subnet" {
  value = aws_subnet.private
}

output "private_extra_subnet" {
  value = aws_subnet.private-extra
}

output "nat_public_ip" {
  value = aws_eip.nat[*].public_ip
}

output "nat_id" {
  value = aws_nat_gateway.nat[*].id
}

output "route_table_id" {
  value = aws_route_table.private[*].id
}
