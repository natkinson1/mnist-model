variable "sagemaker-endpoint-name" {
    description = "The name of the private SageMaker model endpoint"
    type = string
}

variable "aws-region" {
    description = "AWS region for infrastructure"
    default = "ap-southeast-2"
}