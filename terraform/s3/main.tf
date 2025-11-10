terraform {
    backend "s3" {
        bucket = "terraform-mnist-state041125"
        key = "tf-infra/s3/terraform.tfstate"
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

resource "aws_s3_bucket" "mnist-model-bucket09112025" {
    bucket = "mnist-model-bucket-09112025"
    force_destroy = true
}

output "mnist-bucket-name" {
    description = "Name of bucket to store model artifacts"
    value = aws_s3_bucket.mnist-model-bucket09112025.name
}