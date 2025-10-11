resource "aws_instance" "ec2_application1" {
  count         = var.create_instance ? 1 : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro" 
  subnet_id     = "subnet-072dd71b1d3f23e22" 
  tags = {
    Name = "application1"
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


resource "aws_lb" "application" {
  name               = "application"
  load_balancer_type = "application"
  subnets            = ["subnet-072dd71b1d3f23e22"]
  security_groups    = [aws_security_group.web_traffic.id]
  internal           = false
}


resource "aws_security_group" "web_traffic" {
  name        = "web-server-sg"
  description = "Allow HTTP and HTTPS inbound traffic"
  
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "web-traffic-sg"
  }
}
