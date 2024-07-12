locals {
  application_name = "scoot-${var.environment}-${var.app_name}"
  lambda_name      = "scoot-${var.environment}-${var.app_name}"
  binaries_archive_name = "${local.lambda_name}-${var.ci_pipeline_id}.zip"
}

# start of Lambda zip deployment

data "archive_file" "api" {
  type = "zip"

  source_dir  = var.publish_path
  output_path = "${path.module}/${local.binaries_archive_name}"
}

data "aws_kms_key" "api" {
  key_id = "alias/${local.application_name}"
}

#end of lambda zip deployment

#start of lambda creation
data "aws_iam_role" "api" {
  name = local.application_name
}

data "aws_ecr_repository" "api" {
  name = local.application_name
}

resource "aws_lambda_function" "lambda_function" {
  function_name = local.lambda_name

  package_type = "Image"
  publish      = true
  image_uri    = "${data.aws_ecr_repository.api.repository_url}:${var.app_name}-ci-${var.ci_pipeline_id}"

  source_code_hash = data.archive_file.api.output_base64sha256
  kms_key_arn      = data.aws_kms_key.api.arn

  image_config {
    command = [var.function_handler]
  }

  memory_size = 1024
  timeout     = "30"
  role        = data.aws_iam_role.api.arn
}

#end of lambda creation

#gateway lambda Integration
data "aws_api_gateway_rest_api" "api" {
  name = var.parent_gateway_name
}

# start resource ##############################
data "aws_api_gateway_resource" "resource" {
  for_each    = toset(var.api_version_list)
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  path        = "/${each.value}/${var.gateway_path}"
}
resource "aws_api_gateway_method" "resource_method" {
  for_each         = toset(var.api_version_list)
  rest_api_id      = data.aws_api_gateway_rest_api.api.id
  resource_id      = data.aws_api_gateway_resource.resource[each.key].id
  authorization    = "NONE"
  http_method      = "ANY"
  api_key_required = false
}

resource "aws_api_gateway_integration" "resource_integration" {
  for_each    = toset(var.api_version_list)
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  resource_id = data.aws_api_gateway_resource.resource[each.key].id
  http_method = aws_api_gateway_method.resource_method[each.key].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn

  depends_on = [aws_lambda_function.lambda_function]
}
# end resource ####################


resource "aws_lambda_permission" "resource_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.aws_api_gateway_rest_api.api.execution_arn}/*"

  depends_on = [
    aws_api_gateway_method.resource_method
  ]
}


resource "aws_api_gateway_deployment" "api_deployment" {
  for_each    = toset(var.api_version_list)
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  stage_name  = var.environment
  triggers = {
    redeployment = sha1(jsonencode([
      md5(file("api.tf")),
      aws_api_gateway_method.resource_method[each.key].id,
      aws_api_gateway_integration.resource_integration[each.key].id
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_integration.resource_integration,
    aws_lambda_function.lambda_function,
    aws_api_gateway_method.resource_method,
    aws_lambda_permission.resource_permission
  ]
}