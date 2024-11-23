# Create IAM role for EC2 instances
resource "aws_iam_role" "app_ec2_role" {
  name               = "${var.env_prefix}-app-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    Name = "${var.env_prefix}-app-ec2-role"
  }
}

# Attach SSM policy to the role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create iam instance profile
resource "aws_iam_instance_profile" "app_ec2_instance_profile" {
  name = "${var.env_prefix}-app-ec2-instance-profile"
  role = aws_iam_role.app_ec2_role.name
}

# Create the Launch template
resource "aws_launch_template" "app_launch_template" {
  name                   = "${var.env_prefix}-app-launch-template"
  vpc_security_group_ids = [var.app_sg_id]
  user_data              = var.user_data_file
  instance_type          = var.instance_type
  image_id               = var.ami_id
  iam_instance_profile {
    arn = aws_iam_instance_profile.app_ec2_instance_profile.arn
  }
}
# Create alb target group
resource "aws_alb_target_group" "app_alb_target_group" {
  name        = "${var.env_prefix}-app-alb-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

# Create autoscaling group
resource "aws_autoscaling_group" "app_autoscaling_group" {
  name = "${var.env_prefix}-app-autoscaling-group"
  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [aws_alb_target_group.app_alb_target_group.arn]
  min_size                  = 1
  max_size                  = 1
  wait_for_capacity_timeout = 0
  termination_policies      = ["OldestInstance"]
  tag {
    key                 = "Name"
    value               = "${var.env_prefix}-app-instance"
    propagate_at_launch = true
  }
  tag {
    key                 = "env"
    value               = var.env_prefix
    propagate_at_launch = true
  }
}

# Create ALB
resource "aws_alb" "app_alb" {
  name               = "${var.env_prefix}-app-alb"
  subnets            = var.public_subnet_ids
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  tags = {
    Name = "${var.env_prefix}-app-alb"
    env  = var.env_prefix
  }
}

# Attach http listener to ALB
resource "aws_alb_listener" "app_alb_http_listener" {
  load_balancer_arn = aws_alb.app_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create ACM certificate
# resource "aws_acm_certificate" "cert" {
#   domain_name       = "example.com"
#   validation_method = "DNS"

#   tags = {
#     Environment = "poc"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# # Create certificate validation
# resource "aws_acm_certificate" "example" {
#   domain_name       = "example.com"
#   validation_method = "DNS"
# }

# data "aws_route53_zone" "example" {
#   name         = "example.com"
#   private_zone = false
# }

# resource "aws_route53_record" "example" {
#   for_each = {
#     for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.example.zone_id
# }

# resource "aws_acm_certificate_validation" "example" {
#   certificate_arn         = aws_acm_certificate.example.arn
#   validation_record_fqdns = [for record in aws_route53_record.example : record.fqdn]
# }

# resource "aws_lb_listener" "app_alb_https_listener" {
#   load_balancer_arn = aws_alb.app_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   default_action {
#     target_group_arn = aws_alb_target_group.app_alb_target_group.arn
#     type             = "forward"
#   }

#   certificate_arn = aws_acm_certificate_validation.example.certificate_arn
# }