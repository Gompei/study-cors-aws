########################################################
# Lambda
########################################################
resource "aws_lambda_function" "lambda_function" {
  function_name    = "${var.project_name}-lambda"
  filename         = "lambda.zip"
  handler          = "handler"
  source_code_hash = sha256(filebase64("lambda.zip"))
  role             = aws_iam_role.lambda_iam_role.arn
  publish          = true
  runtime          = "go1.x"
  memory_size      = 128
  timeout          = 3
}

resource "aws_iam_role" "lambda_iam_role" {
  name                = "${var.project_name}-lmabda-role"
  assume_role_policy  = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}

########################################################
# Lambda Permission
########################################################
resource "aws_lambda_permission" "lambda_permission" {
  for_each      = toset(local.http_methods)
  statement_id  = "allow-api-gateway-${each.value}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_rest_api.execution_arn}/*/${each.value}/${aws_api_gateway_resource.api_gateway_resource.path_part}"
}

