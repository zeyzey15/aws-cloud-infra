resource "aws_sns_topic" "jumphost" {
  name = "jumphost" 
}

resource "aws_sns_topic_subscription" "personal-email" {
  topic_arn = aws_sns_topic.jumphost.arn
  protocol  = "email"
  endpoint  = var.email
}  

resource "aws_sns_topic" "s3_bucket" {
  name = "s3_busket"
}

resource "aws_sns_topic_subscription" "user_updates_email_target" {
  topic_arn = aws_sns_topic.s3_bucket.arn
  protocol  = "email"
  endpoint  = var.email
}

# SNS topic subscription for Lambda removed - S3 now triggers Lambda directly
# resource "aws_sns_topic_subscription" "s3_to_lambda" {
#   topic_arn = aws_sns_topic.s3_bucket.arn
#   protocol  = "lambda"
#   endpoint  = aws_lambda_function.s3_processor.arn
#
#   # Ensure the permission allowing SNS to invoke the Lambda exists before creating the subscription
#   depends_on = [
#     aws_lambda_permission.allow_sns_invoke,
#   ]
# }

data "aws_iam_policy_document" "s3_topic_policy" {
  statement {
    sid = "AllowS3ToPublish"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "SNS:Publish",
    ]

    resources = [
      aws_sns_topic.s3_bucket.arn,
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        aws_s3_bucket.bucket_data.arn,
      ]
    }
  }
}

resource "aws_sns_topic_policy" "s3_bucket_policy" {
  arn    = aws_sns_topic.s3_bucket.arn
  policy = data.aws_iam_policy_document.s3_topic_policy.json
}