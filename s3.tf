resource "aws_s3_bucket" "bucket_data" {
  bucket = "bucket-data${random_string.bucket.result}"
}

resource "aws_s3_bucket_notification" "bucket_notifications" {
  bucket = aws_s3_bucket.bucket_data.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    # send create/overwrite and delete events directly to Lambda
    events = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    
    # Optional: Add filters to be more specific about which objects trigger the Lambda
    # filter_prefix = "uploads/"           # Only objects in uploads/ folder
    # filter_suffix = ".txt"               # Only .txt files
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke,
  ]
}