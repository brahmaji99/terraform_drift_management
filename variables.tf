variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "bucket_name" {
  description = "Name of the demo S3 bucket"
  type        = string
  default     = "terraform-demo-bucket-ai2026"
}


