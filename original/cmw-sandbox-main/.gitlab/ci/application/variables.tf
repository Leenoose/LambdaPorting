# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "ap-southeast-2"
}

variable "environment" {
  type    = string
  default = "test"
}

variable "app_name" {
  type = string
}

variable "publish_path" {
  type = string
}

variable "parent_gateway_name" {
  type = string
}

variable "function_handler" {
  type = string
}

variable "gateway_path" {
  type = string
}

variable "api_version_list" {
  type = list(string)
}

variable "ci_pipeline_id"{
type = string
}