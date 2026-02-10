output "api_gateway_invoke_url" {
  description = "URL to invoke the API (POST to /message to send to SQS)"
  value       = "${aws_api_gateway_stage.default.invoke_url}/message"
}

output "api_gateway_rest_api_id" {
  description = "REST API ID"
  value       = aws_api_gateway_rest_api.api.id
}

output "sqs_queue_url" {
  description = "URL of the SQS queue (for Lambda event source mapping)"
  value       = aws_sqs_queue.api_requests.url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue (for Lambda permissions / event source)"
  value       = aws_sqs_queue.api_requests.arn
}

output "sqs_queue_name" {
  description = "Name of the SQS queue"
  value       = aws_sqs_queue.api_requests.name
}

output "lambda_consumer_function_name" {
  description = "Name of the Lambda consumer function"
  value       = aws_lambda_function.sqs_consumer.function_name
}

output "lambda_consumer_function_arn" {
  description = "ARN of the Lambda consumer function"
  value       = aws_lambda_function.sqs_consumer.arn
}
