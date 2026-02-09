terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Resource 1: Demo S3 bucket
resource "aws_s3_bucket" "demo_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "demo-bucket"
    Environment = "dev"
  }
}

# Resource 2: Demo EC2 instance
resource "aws_instance" "demo_ec2" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  tags = {
    Name        = "demo-ec2"
    Environment = "dev"
  }
}
