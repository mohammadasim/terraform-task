variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3a.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the instances"
  default     = "ami-0e2c8caa4b6378d8c"
}

variable "user_data_file" {
  type        = string
  description = "Path to the user data file"
}

variable "env_prefix" {
  type        = string
  description = "Prefix for the environment"
  default     = "poc"
}

variable "app_sg_id" {
  type        = string
  description = "ID of the application security group"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "alb_sg_id" {
  type        = string
  description = "ID of the ALB security group"
}