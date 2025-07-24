# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get the default security group in the default VPC
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Use one of the subnets (e.g., the first one)
data "aws_subnet" "default" {
  id = tolist(data.aws_subnets.default.ids)[0]
}


