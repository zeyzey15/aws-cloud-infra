

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
