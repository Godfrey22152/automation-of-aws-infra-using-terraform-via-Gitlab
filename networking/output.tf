output "dev_project_vpc_id" {
  value = aws_vpc.dev_project_vpc.id
}

output "dev_project_public_subnets" {
  value = aws_subnet.dev_project_public_subnets.*.id
}

output "public_subnet_cidr_block" {
  value = aws_subnet.dev_project_public_subnets.*.cidr_block
}

output "aws_internet_gateway" {
  value = aws_internet_gateway.dev_project_public_internet_gateway.id
}
