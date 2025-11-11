variable "sagemaker_endpoint_url" {
  description = "The URL of the private SageMaker endpoint"
  type        = string
  default     = "https://runtime.sagemaker.ap-southeast-2.amazonaws.com/endpoints/mnist-model-endpoint/invocations"
}

variable "aws-region" {
    description = "AWS region for infrastructure"
    default = "ap-southeast-2"
}