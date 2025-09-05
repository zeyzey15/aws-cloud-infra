resource "aws_s3_bucket" "bucket_data" {
  bucket = "bucket_data${random_string.bucket.result}"
}

resource "aws_s3_bucket_notification" "bucket_notifications" {
  bucket = aws_s3_bucket.bucket_data.id

  topic {
    topic_arn = aws_sns_topic.s3_bucket.arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_sns_topic_policy.s3_bucket_policy,
  ]
}