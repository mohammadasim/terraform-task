output "app_sg_id" {
  value       = aws_security_group.app_sg.id
  description = "ID of the app security group"
}

output "db_sg_id" {
  value       = aws_security_group.db_sg.id
  description = "ID of the DB security group"
}

output "alb_sg_id" {
  value       = aws_security_group.alb_sg.id
  description = "ID of the ALB security group"
}