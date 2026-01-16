variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "EC2 SSH Key Pair"
  type        = string
  default     = "dev-portfolio-key"
}
