variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "apitosqs"
}

variable "api_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "default"
}

variable "queue_name" {
  description = "Name of the SQS queue that receives API requests"
  type        = string
  default     = "api-requests"
}

variable "lambda_consumer_image_uri" {
  description = "ECR image URI for the Lambda consumer (e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/my-repo:latest). When set, an image-based Lambda is created and wired to the SQS queue."
  type        = string
  default     = ""
}

variable "lambda_consumer_timeout" {
  description = "Timeout in seconds for the Lambda consumer"
  type        = number
  default     = 30
}

variable "lambda_consumer_memory_size" {
  description = "Memory size in MB for the Lambda consumer"
  type        = number
  default     = 128
}

variable "api_key" {
  description = "API key for the API"
  type        = string
  default     = ""
}

variable "api_allowed_source_ips" {
  description = "List of CIDR blocks allowed to invoke the API (e.g. [\"1.2.3.4/32\", \"10.0.0.0/8\"]). Empty = no IP restriction."
  type        = list(string)
  sensitive   = true
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  sensitive   = true
}