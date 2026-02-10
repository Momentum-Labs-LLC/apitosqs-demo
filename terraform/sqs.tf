resource "aws_sqs_queue" "api_requests" {
  name                       = "${var.project_name}-${var.queue_name}"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600 # 4 days
  receive_wait_time_seconds  = 0
  delay_seconds              = 0

  tags = {
    Name    = "${var.project_name}-${var.queue_name}"
    Project = var.project_name
  }
}

# Allow Lambda consumer to consume from this queue
resource "aws_sqs_queue_policy" "api_requests" {
  queue_url = aws_sqs_queue.api_requests.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowLambdaConsumer"
        Effect    = "Allow"
        Principal = { AWS = aws_iam_role.lambda_consumer.arn }
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.api_requests.arn
      }
    ]
  })
}
