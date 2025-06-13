module "ec2_instance" {

  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "giuseppe_companyrome"

  instance_type          = "t2.micro"
  key_name               = "zey"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.giuseppe_sg.id] 
  subnet_id              = data.aws_subnets.default.ids[1]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
} 

resource "aws_security_group" "giuseppe_sg" {
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}