terraform {
    backend "s3" {
        bucket = "terraform-mnist-state041125"
        key = "tf-infra/sagemaker/terraform.tfstate"
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

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_sagemaker_model" "mnist-model" {
    name = "mnist-model"
    execution_role_arn = aws_iam_role.mnist_user.arn

    primary_container {
        image = var.image_uri
        model_data_url = var.model_data_url
    }
}

resource "aws_sagemaker_endpoint" "mnist-model-endpoint" {
    name = "mnist-model-endpoint"
    endpoint_config_name = aws_sagemaker_endpoint_configuration.mnist-model-endpoint-config.name
}

resource "aws_sagemaker_endpoint_configuration" "mnist-model-endpoint-config" {
    name = "mnist-model-endpoint-config"
    production_variants {
        variant_name = "v1"
        model_name = aws_sagemaker_model.mnist-model.name
        initial_instance_count = 1
        instance_type = "ml.m4.xlarge"
        # serverless_config {
        #     max_concurrency = 1
        #     memory_size_in_mb = 1024
        # }
    }
    data_capture_config {
        initial_sampling_percentage = 100
        destination_s3_uri = "s3://terraform-mnist-state041125/logs/"
        capture_options {
            capture_mode = "InputAndOutput"
        }
    }
}

resource "aws_iam_role" "mnist_user" {
  assume_role_policy = data.aws_iam_policy_document.mnist_model_role.json
}

data "aws_iam_policy_document" "mnist_model_role" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["sagemaker.amazonaws.com"]
        }
    }
}

data "aws_iam_policy_document" "ecr_pull_policy" {
    statement {
        sid = "AllowECRPull"

        actions = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "s3:GetObject"
        ]

        resources = ["*"]
    }
}

resource "aws_iam_role_policy" "mnist_ecr_pull" {
  name   = "mnist-ecr-pull-policy"
  role   = aws_iam_role.mnist_user.id
  policy = data.aws_iam_policy_document.ecr_pull_policy.json
}
