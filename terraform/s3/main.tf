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

resource "aws_s3_bucket" "mnist-model-bucket09112025" {
    bucket = "mnist-model-bucket-09112025"
    force_destroy = true
}

output "mnist-bucket-name" {
    description = "Name of bucket to store model artifacts"
    value = aws_s3_bucket.mnist-model-bucket09112025.id
}