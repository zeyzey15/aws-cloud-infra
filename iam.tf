resource "aws_iam_user" "tf_manager" {
  name = "tf_manager"
}

resource "aws_iam_group" "readonly_group" {
  name = "ReadOnlyGroup"
}

resource "aws_iam_user_group_membership" "tf_manager_readonly" {
  user = aws_iam_user.tf_manager.name
  groups = [
    aws_iam_group.readonly_group.name
  ]
}

resource "aws_iam_group_policy_attachment" "readonly_policy_attach" {
  group      = aws_iam_group.readonly_group.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}


resource "aws_iam_user_policy_attachment" "readonly_policy_attach" {
  user       = "admin"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}



#First Compute-Limited-FreeTier-Policy
resource "aws_iam_policy" "compute_limited_free_tier" {
  name        = "First-Compute-Limited-FreeTier-Policy"
  description = "Allow only Free Tier EC2 instance types"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ec2:RunInstances", "ec2:StartInstances", "ec2:StopInstances", "ec2:TerminateInstances"],
        Resource = "*",
        Condition = {
          StringEquals = {
            "ec2:InstanceType" = ["t2.micro", "t3.micro", "t4g.micro"]
          }
        }
      }
    ]
  })
}

# 2. Second Storage-Limited-FreeTier-Policy
resource "aws_iam_policy" "storage_limited_free_tier" {
  name        = "Second-Storage-Limited-FreeTier-Policy"
  description = "Restrict EC2 EBS to 15GB, RDS to 20GB, allow full S3"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ec2:*"],
        Resource = "*",
        Condition = {
          NumericLessThanEquals = {
            "ec2:VolumeSize" = 15
          }
        }
      },
      {
        Effect   = "Allow",
        Action   = ["rds:*"],
        Resource = "*",
        Condition = {
          NumericLessThanEquals = {
            "rds:AllocatedStorage" = 20
          }
        }
      },
      {
        Effect   = "Allow",
        Action   = ["s3:*"],
        Resource = "*"
      }
    ]
  })
}


# 3. Third DynamoDB-Limited-FreeTier-Policy
resource "aws_iam_policy" "dynamodb_limited_free_tier" {
  name        = "Third-DynamoDB-Limited-FreeTier-Policy"
  description = "Restrict non-free-tier options in DynamoDB"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Deny",
        Action   = ["dynamodb:CreateTable", "dynamodb:UpdateTable", "dynamodb:DeleteTable"],
        Resource = "*",
        Condition = {
          StringNotEquals = {
            "dynamodb:TableClass" = "STANDARD"
          }
        }
      }
    ]
  })
}


# 4. Last Non-FreeTier-Deny-Policy
resource "aws_iam_policy" "non_free_tier_deny" {
  name        = "Last-Non-FreeTier-Deny-Policy"
  description = "Deny creation of non-Free Tier services only"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Deny",
        Action   = ["ec2:RunInstances", "rds:CreateDBInstance", "dynamodb:CreateTable"],
        Resource = "*",
        Condition = {
          StringNotEqualsIfExists = {
            "ec2:InstanceType"    = ["t2.micro", "t3.micro", "t4g.micro"],
            "rds:DBInstanceClass" = ["db.t2.micro", "db.t3.micro", "db.t4g.micro"],
            "dynamodb:TableClass" = "STANDARD"
          }
        }
      }
    ]
  })
}

