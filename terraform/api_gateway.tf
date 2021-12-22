########################################################
# API Gateway
########################################################
resource "aws_api_gateway_rest_api" "api_gateway_rest_api" {
  name        = "${var.project_name}-api-gateway-rest"
  description = "${var.project_name}-api-gateway-rest"
}

########################################################
# API Gateway Error Response
########################################################
resource "aws_api_gateway_gateway_response" "default_4xx_response" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_rest_api.id
  response_type = "DEFAULT_4XX"
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
  }
}
resource "aws_api_gateway_gateway_response" "default_5xx_response" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_rest_api.id
  response_type = "DEFAULT_5XX"
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
  }
}

########################################################
# API Gateway Resource Path
########################################################
resource "aws_api_gateway_resource" "api_gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_rest_api.root_resource_id
  path_part   = "test"
}

########################################################
# API Gateway Method
########################################################
locals {
  http_methods = ["GET", "POST"]
}
resource "aws_api_gateway_method" "methods" {
  for_each      = toset(local.http_methods)
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id   = aws_api_gateway_resource.api_gateway_resource.id
  http_method   = each.value
  authorization = "NONE"
}
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id   = aws_api_gateway_resource.api_gateway_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

########################################################
# API Gateway Integration
########################################################
resource "aws_api_gateway_integration" "integrations" {
  for_each                = toset(local.http_methods)
  depends_on              = [aws_api_gateway_method.methods]
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id             = aws_api_gateway_resource.api_gateway_resource.id
  http_method             = aws_api_gateway_method.methods[each.value].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}
resource "aws_api_gateway_integration" "options" {
  depends_on  = [aws_api_gateway_method.options]
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.api_gateway_resource.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}

########################################################
# API Gateway Method Response
########################################################
resource "aws_api_gateway_method_response" "methods_response" {
  for_each    = toset(local.http_methods)
  depends_on  = [aws_api_gateway_method.methods]
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.api_gateway_resource.id
  http_method = aws_api_gateway_method.methods[each.value].http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.api_gateway_resource.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

########################################################
# API Gateway Integration Response
########################################################
resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.api_gateway_resource.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    # 今回はサンプルの為、すべてのオリジンを許可しています。
    # 本番・ステージング環境では非推奨です。
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

########################################################
# Deploy API Gateway
########################################################
resource "aws_api_gateway_deployment" "pi_gateway_deployment" {
  depends_on = [
    aws_api_gateway_integration.integrations,
    aws_api_gateway_integration.options
  ]

  rest_api_id = aws_api_gateway_rest_api.api_gateway_rest_api.id
  // 常にデプロイ
  stage_description = "timestamp = ${timestamp()}"
  stage_name        = "api"
  lifecycle {
    create_before_destroy = true
  }
}
