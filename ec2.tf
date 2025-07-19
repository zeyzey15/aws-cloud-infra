module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.0.0"
  iam_instance_profile = aws_iam_instance_profile.giuseppe_profile.name 
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y snapd
              systemctl enable snapd
              systemctl start snapd
              snap install amazon-ssm-agent --classic
              systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
              systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
              EOF 

name = "giuseppe_companyrome"

  instance_type          = "t2.micro"
  monitoring             = true
  ami                    = "ami-01f23391a59163da9" 
  root_block_device = [{
    device_name           = "/dev/sda1"
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  
  }]
  
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

# IAM Assume Role Policy for EC2
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# IAM Role for EC2 to use SSM
resource "aws_iam_role" "giuseppe_role" {
  name               = "test_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach the AmazonSSMManagedInstanceCore policy to the role
resource "aws_iam_role_policy_attachment" "giuseppe_policy" {
  role       = aws_iam_role.giuseppe_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create an IAM Instance Profile for the role
resource "aws_iam_instance_profile" "giuseppe_profile" {
  name = "EC2InstanceProfileSSM"
  role = aws_iam_role.giuseppe_role.name
}
