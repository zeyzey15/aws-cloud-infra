resource "aws_instance" "JumpHost-SproutEats" {
  count             = var.create_jumphost ? 1 : 0
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t2.micro"
  availability_zone = "eu-west-1c"
  subnet_id         = var.subnets_public[0]
  security_groups   = [aws_security_group.jumphost[0].id]
  tags = {
    Name = "JumpHost-SproutEats"
  }
}



data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "jumphost" {
  count  = var.create_jumphost ? 1 : 0
  name   = "sg"
  vpc_id = var.vpc_zey
}

resource "aws_security_group_rule" "allow_all" {
  count             = var.create_jumphost ? 1 : 0
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jumphost[0].id
}

resource "aws_security_group_rule" "allow_ssh_jumphost" {
  count             = var.create_jumphost ? 1 : 0
  type              = "ingress"
  to_port           = 22
  protocol          = "tcp"
  from_port         = 22
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jumphost[0].id
}
