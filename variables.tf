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

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID"
  type        = string
  default     = "ami-02781fbdc79017564"
}
