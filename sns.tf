resource "aws_sns_topic" "notifications" {
  name = var.sns_topic_name != "" ? var.sns_topic_name : "infra-notifications-${random_id.sns_suffix.hex}"
}

resource "random_id" "sns_suffix" {
  byte_length = 4
}
