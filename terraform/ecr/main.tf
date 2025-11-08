terraform {
    backend "s3" {
        bucket = "terraform-mnist-state041125"
        key = "tf-infra/ecr/terraform.tfstate"
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

resource "aws_ecr_repository" "mnist-repo" {
    name = "mnist-repo"
}

output "mnist-repo-name" {
    description = "mnist ECR name"
    value = aws_ecr_repository.mnist-repo.name
}
