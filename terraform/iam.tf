# IAM role for API Gateway to call SQS SendMessage
resource "aws_iam_role" "api_gateway_sqs" {
  provider = aws.member
  name     = "${var.project_name}-api-gateway-sqs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "api_gateway_sqs_send" {
  provider = aws.member
  name     = "sqs-send-message"
  role     = aws_iam_role.api_gateway_sqs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.api_requests.arn
      }
    ]
  })
}

# IAM role for Lambda consumer (image-based) to read from SQS
# resource "aws_iam_role" "lambda_consumer" {
#   name = "${var.project_name}-lambda-consumer-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# # Lambda: CloudWatch Logs + SQS consume
# resource "aws_iam_role_policy" "lambda_consumer" {
#   name = "lambda-consumer-sqs-logs"
#   role = aws_iam_role.lambda_consumer.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
#         Resource = "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${var.project_name}-sqs-consumer:*"
#       },
#       {
#         Effect   = "Allow"
#         Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
#         Resource = aws_sqs_queue.api_requests.arn
#       }
#     ]
#   })
# }
