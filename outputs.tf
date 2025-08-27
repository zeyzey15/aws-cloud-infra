output "default_sg_id" {
  value = data.aws_security_group.default.id
}

output "default_subnet_ids" {
  value = data.aws_subnets.default.ids
}

output "first_default_subnet_cidr_block" {
  value = data.aws_subnet.default.cidr_block
}


