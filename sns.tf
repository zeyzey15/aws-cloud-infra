resource "aws_sns_topic" "jumphost" {
  name = "jumphost" 
}

resource "aws_sns_topic_subscription" "personal-email" {
  topic_arn = aws_sns_topic.jumphost.arn
  protocol  = "email"
  endpoint  = var.email
}  