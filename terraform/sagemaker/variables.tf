variable "image_uri" {
    description = "Custom docker image uri for Sagemaker model."
    type = string
}

variable "model_data_url" {
    description = "Directory of model artifact"
    type = string
}