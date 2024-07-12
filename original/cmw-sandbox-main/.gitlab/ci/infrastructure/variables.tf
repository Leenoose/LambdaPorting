variable "aws_region" {
  description = "AWS region for all resources."
  type    = string
  default = "ap-southeast-1"
}

variable "environment" {
  type    = string
  default = "test"
}

variable "app_name" {
  type = string
}

variable "parent_gateway_name" {
  type = string
}