variable "aws_region" {
  default = "eu-north-1"
}

variable "bucket_name" {
  default = "terraform-drift-demo-ai2026"
}

variable "ami_id" {
  description = "Amazon Linux AMI"
  type        = string
  default     = "ami-08d26f9b5f60f8f95"
}
