variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "AWS key pair name"
  type        = string
  default     = "puppet"
}

variable "private_key_path" {
  description = "Path to private key file"
  type        = string
  default     = "./puppet.pem"
}