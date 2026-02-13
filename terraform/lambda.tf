# # Image-based Lambda consumer for the SQS queue
# resource "aws_lambda_function" "sqs_consumer" {
#   function_name = "${var.project_name}-sqs-consumer"
#   role          = aws_iam_role.lambda_consumer.arn
#   package_type  = "Image"
#   image_uri     = var.lambda_consumer_image_uri

#   timeout     = var.lambda_consumer_timeout
#   memory_size = var.lambda_consumer_memory_size

#   environment {
#     variables = {
#       API_KEY = var.api_key
#     }
#   }

#   tags = {
#     Name    = "${var.project_name}-sqs-consumer"
#     Project = var.project_name
#   }
# }

# # Trigger Lambda when messages arrive on the queue
# resource "aws_lambda_event_source_mapping" "sqs" {
#   event_source_arn = aws_sqs_queue.api_requests.arn
#   function_name    = aws_lambda_function.sqs_consumer.function_name
#   batch_size       = 10
# }
