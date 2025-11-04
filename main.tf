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

output "mnist-repo-name" {
    description = "mnist ECR name"
    value = aws_ecr_repository.mnist-repo.name
}
