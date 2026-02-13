resource "aws_sqs_queue" "api_requests_dlq" {
  provider                  = aws.member
  name                      = "${var.project_name}-${var.queue_name}-dlq"
  message_retention_seconds = 1209600 # 14 days (max for DLQ)

  tags = {
    Name    = "${var.project_name}-${var.queue_name}-dlq"
    Project = var.project_name
  }
}

resource "aws_sqs_queue" "api_requests" {
  provider                   = aws.member
  name                       = "${var.project_name}-${var.queue_name}"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600 # 4 days
  receive_wait_time_seconds  = 0
  delay_seconds              = 0

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.api_requests_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name    = "${var.project_name}-${var.queue_name}"
    Project = var.project_name
  }
}

# Allow Lambda consumer to consume from this queue
# resource "aws_sqs_queue_policy" "api_requests" {
#   provider  = aws.member
#   queue_url = aws_sqs_queue.api_requests.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid       = "AllowLambdaConsumer"
#         Effect    = "Allow"
#         Principal = { AWS = aws_iam_role.lambda_consumer.arn }
#         Action = [
#           "sqs:ReceiveMessage",
#           "sqs:DeleteMessage",
#           "sqs:GetQueueAttributes"
#         ]
#         Resource = aws_sqs_queue.api_requests.arn
#       }
#     ]
#   })
# }
