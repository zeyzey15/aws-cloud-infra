# Create Lambda deployment package from external files
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda/lambda_function.zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  # 'excludes' not supported when using source_file (single file archive)
}


# Lambda function
resource "aws_lambda_function" "s3_processor" {
  lifecycle {
    ignore_changes = [ filename ]
  }
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "s3-event-processor"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.9"
  timeout         = 60
  memory_size      = 256
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      ENABLE_DETAILED_LOGGING = false
      LOG_LEVEL  = "DEBUG"
      SNS_TOPIC_ARN = aws_sns_topic.s3_bucket.arn
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_policy,
    aws_cloudwatch_log_group.lambda_logs
  ]
} 

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/s3-event-processor"
  retention_in_days = 14
}

# Lambda permission for S3 to invoke the function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket_data.arn
}






