terraform {
    backend "s3" {
        bucket = "terraform-mnist-state041125"
        key = "tf-infra/gateway/terraform.tfstate"
        region = "ap-southeast-2"
        encrypt = true
    }
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 6.0"
        }
    }
}

resource "aws_iam_role" "apigw_sagemaker_role" {
  name = "apigw_sagemaker_invoke_role"

  assume_role_policy = jsonencode({
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

resource "aws_iam_role_policy" "apigw_sagemaker_policy" {
  name   = "apigw-sagemaker-policy"
  role   = aws_iam_role.apigw_sagemaker_role.id

  policy = jsonencode({
    Statement = [
      {
        Effect = "Allow"
        Action = "sagemaker:InvokeEndpoint"
        Resource = "arn:aws:sagemaker:ap-southeast-2:111029214708:endpoint/mnist-model-endpoint"
      }
    ]
  })
}

resource "aws_api_gateway_rest_api" "mnist-rest-api" {
    name = "mnist-api-gateway"
}

resource "aws_api_gateway_resource" "mnist-api-gateway-resource" {
    parent_id   = aws_api_gateway_rest_api.mnist-rest-api.root_resource_id
    rest_api_id = aws_api_gateway_rest_api.mnist-rest-api.id
    path_part   = "predict"
}

resource "aws_api_gateway_method" "mnist-gateway-method" {
    authorization = "NONE"
    http_method   = "POST"
    resource_id   = aws_api_gateway_resource.mnist-api-gateway-resource.id
    rest_api_id   = aws_api_gateway_rest_api.mnist-rest-api.id
}

resource "aws_api_gateway_integration" "mnist-api-integration" {
    http_method = aws_api_gateway_method.mnist-gateway-method.http_method
    resource_id = aws_api_gateway_resource.mnist-api-gateway-resource.id
    rest_api_id = aws_api_gateway_rest_api.mnist-rest-api.id
    integration_http_method = "POST"
    type = "AWS"
    # uri = "arn:aws:sagemaker:ap-southeast-2:111029214708:endpoint/mnist-model-endpoint/invocations"
    uri = "arn:aws:apigateway:${var.aws-region}:runtime.sagemaker:path/endpoints/mnist-model-endpoint/invocations"
    credentials = aws_iam_role.apigw_sagemaker_role.arn
}

resource "aws_api_gateway_deployment" "mnist-api-deployment" {
    depends_on = [aws_api_gateway_integration.mnist-api-integration]
    rest_api_id = aws_api_gateway_rest_api.mnist-rest-api.id
}

resource "aws_api_gateway_stage" "mnist-rest-api-stage" {
    deployment_id = aws_api_gateway_deployment.mnist-api-deployment.id
    rest_api_id   = aws_api_gateway_rest_api.mnist-rest-api.id
    stage_name    = "predict"
}

resource "aws_api_gateway_method_response" "mnist-method-response" {
    rest_api_id = aws_api_gateway_rest_api.mnist-rest-api.id
    resource_id = aws_api_gateway_resource.mnist-api-gateway-resource.id
    http_method = aws_api_gateway_method.mnist-gateway-method.http_method
    status_code = "200"

    response_models = {
        "application/json" = "Empty"
    }
}

resource "aws_api_gateway_integration_response" "success" {
    rest_api_id = aws_api_gateway_rest_api.mnist-rest-api.id
    resource_id = aws_api_gateway_resource.mnist-api-gateway-resource.id
    http_method = aws_api_gateway_method.mnist-gateway-method.http_method
    status_code = "200"

    response_templates = {
        "application/json" = "$input.body"
    }
}



output "invoke_url" {
    description = "Rest API URL"
    value = aws_api_gateway_stage.mnist-rest-api-stage.invoke_url
}