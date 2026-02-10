# API Gateway → SQS Terraform

This Terraform setup creates:

- **API Gateway REST API** with a single `POST /message` endpoint that writes directly to SQS (no Lambda in the path).
- **SQS queue** whose messages contain the HTTP request **body**, **headers**, and client **IP address**.
- **IAM role** for API Gateway to call `sqs:SendMessage` on the queue.

The SQS queue can be consumed by an **image-based Lambda** (optional): set `lambda_consumer_image_uri` to your ECR image URI and Terraform will create the Lambda, IAM role, and SQS event source mapping.

## SQS message format

Each SQS message body is a JSON object:

```json
{
  "body": "<raw HTTP request body as string>",
  "headers": {
    "Content-Type": "application/json",
    "User-Agent": "curl/7.68.0",
    ...
  },
  "sourceIp": "203.0.113.42"
}
```

Your Lambda can parse this JSON from the SQS event’s `Records[].body` to access the original request body, headers, and client IP.

## Usage

1. **Apply**

   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

2. **Invoke the API**

   After apply, use `api_gateway_invoke_url` (e.g. `https://xxxx.execute-api.us-east-1.amazonaws.com/default/message`):

   ```bash
   curl -X POST "$(terraform output -raw api_gateway_invoke_url)" \
     -H "Content-Type: application/json" \
     -d '{"key": "value"}'
   ```

3. **Optional: image-based Lambda consumer**

   Set `lambda_consumer_image_uri` to your ECR image (e.g. `123456789.dkr.ecr.us-east-1.amazonaws.com/my-repo:latest`). Terraform will create the Lambda, grant it SQS access, and add an event source mapping so the Lambda is invoked when messages arrive. Ensure the queue’s **visibility timeout** (default 30s in `sqs.tf`) is at least as long as your Lambda timeout (ideally 6×) to avoid duplicate processing.

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `us-east-1` |
| `project_name` | Prefix for resource names | `apitosqs` |
| `api_stage_name` | API Gateway stage | `default` |
| `queue_name` | SQS queue name suffix | `api-requests` |
| `lambda_consumer_image_uri` | ECR image URI for the Lambda consumer | `""` |
| `lambda_consumer_timeout` | Lambda consumer timeout (seconds) | `30` |
| `lambda_consumer_memory_size` | Lambda consumer memory (MB) | `128` |

## Outputs

- `api_gateway_invoke_url` – Full URL for `POST /message`
- `api_gateway_rest_api_id` – REST API ID
- `sqs_queue_url` – SQS queue URL (for Lambda event source)
- `sqs_queue_arn` – SQS queue ARN (for Lambda event source / IAM)
- `sqs_queue_name` – SQS queue name
- `lambda_consumer_function_name` – Lambda consumer function name
- `lambda_consumer_function_arn` – Lambda consumer function ARN
