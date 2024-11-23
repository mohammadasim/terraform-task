variable "vpc_id" {
  type        = string
  description = "VPC ID for security group."
}
variable "allowed_mysql_cidrs" {
  type        = list(any)
  description = "List of CIDR blocks allowed for mysql access.vpc"
  default     = ["0.0.0.0/0"]
}

variable "alb_allowed_http_cidrs" {
  type        = list(any)
  description = "List of CIDR blocks allowed for http access to ALB"
  default     = ["0.0.0.0/0"]
}