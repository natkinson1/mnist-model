terraform {
    backend "s3" {
        bucket = "terraform-mnist-state041125"
        key = "tf-infra/terraform.tfstate"
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

resource "aws_s3_bucket" "terraform-mnist-state041125" {
    bucket = "terraform-mnist-state041125"
    force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-mnist-state041125-encryption" {
    bucket = aws_s3_bucket.terraform-mnist-state041125.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_versioning" "terraform-mnist-state041125-versioning" {
    bucket = aws_s3_bucket.terraform-mnist-state041125.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_ecr_repository" "mnist-repo" {
    name = "mnist-repo"
}

resource "aws_sagemaker_model" "mnist-model" {
    name = "mnist-model"
    execution_role_arn = aws_iam_role.mnist_user.arn

    primary_container {
        image = aws_ecr_repository.mnist-repo.repository_url
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
        serverless_config {
            max_concurrency = 1
            memory_size_in_mb = 1024
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

output "mnist-repo-name" {
    description = "mnist ECR name"
    value = aws_ecr_repository.mnist-repo.name
}
