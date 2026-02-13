# REST API
resource "aws_api_gateway_rest_api" "api" {
  provider    = aws.member
  name        = "${var.project_name}-api"
  description = "API that forwards requests to SQS with body, headers, and source IP"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name    = "${var.project_name}-api"
    Project = var.project_name
  }
}

data "aws_iam_policy_document" "ip_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = [
      aws_api_gateway_rest_api.api.execution_arn,
      "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.api_allowed_source_ips
    }
  }

  statement {
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = [
      aws_api_gateway_rest_api.api.execution_arn,
      "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
    ]

    condition {
      test     = "NotIpAddress"
      variable = "aws:SourceIp"
      values   = var.api_allowed_source_ips
    }
  }
}

# IP restriction: allow invoke only from specified CIDR blocks (when non-empty)
resource "aws_api_gateway_rest_api_policy" "ip_restriction" {
  provider    = aws.member
  rest_api_id = aws_api_gateway_rest_api.api.id
  policy = data.aws_iam_policy_document.ip_policy.json
}

# Root resource (e.g. POST /)
resource "aws_api_gateway_resource" "root" {
  provider    = aws.member
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "message"
}

# POST method
resource "aws_api_gateway_method" "post" {
  provider      = aws.member
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "POST"
  authorization = "NONE"
  request_parameters = {
    "method.request.header.Content-Type" = false
  }
}

# Integration: API Gateway -> SQS (path override = account-id/queue-name)
resource "aws_api_gateway_integration" "sqs" {
  provider                = aws.member
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.post.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  credentials             = aws_iam_role.api_gateway_sqs.arn
  passthrough_behavior    = "NEVER"

  uri = "arn:aws:apigateway:${var.aws_region}:sqs:path/${var.aws_account_id}/${aws_sqs_queue.api_requests.name}"

  # defining the content type of the request from API Gateway to SQS
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json"                  = file("${path.module}/api_gateway_sqs_mapping.vtl")
    "application/x-www-form-urlencoded" = file("${path.module}/api_gateway_sqs_mapping.vtl")
  }
}

# Method response 200
resource "aws_api_gateway_method_response" "ok" {
  provider    = aws.member
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# Integration response: pass through SQS response
resource "aws_api_gateway_integration_response" "sqs" {
  provider    = aws.member
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = aws_api_gateway_method_response.ok.status_code

  depends_on = [aws_api_gateway_integration.sqs]
}

# Deployment and stage
resource "aws_api_gateway_deployment" "api" {
  provider    = aws.member
  rest_api_id = aws_api_gateway_rest_api.api.id

  # Include policy hash so a new deployment is created when the IP policy changes (API Gateway applies policy only after redeploy)
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.sqs.uri,
      aws_api_gateway_integration.sqs.request_templates,
      nonsensitive(sha1(data.aws_iam_policy_document.ip_policy.json)),
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.sqs,
    aws_api_gateway_integration_response.sqs,
    aws_api_gateway_rest_api_policy.ip_restriction,
  ]
}

resource "aws_api_gateway_stage" "default" {
  provider      = aws.member
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "v1"
}
