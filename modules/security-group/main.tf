resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Application load balancer security group."
  vpc_id      = var.vpc_id
  tags = {
    Name = "alb_sg"
  }
}
resource "aws_vpc_security_group_egress_rule" "alb_sg_egress_rule_http" {
  security_group_id = aws_security_group.alb_sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_sg_egress_rule_https" {
  security_group_id = aws_security_group.alb_sg.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_sg_ingress_rule_http" {
  count             = length(var.alb_allowed_http_cidrs)
  security_group_id = aws_security_group.alb_sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = element(var.alb_allowed_http_cidrs, count.index)
}
resource "aws_vpc_security_group_ingress_rule" "alb_sg_ingress_rule_https" {
  count             = length(var.alb_allowed_http_cidrs)
  security_group_id = aws_security_group.alb_sg.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = element(var.alb_allowed_http_cidrs, count.index)
}


resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Application security group."
  vpc_id      = var.vpc_id
  tags = {
    Name = "app_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "app_sg_egress_rule_http" {
  security_group_id = aws_security_group.app_sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "app_sg_egress_rule_https" {
  security_group_id = aws_security_group.app_sg.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "app_sg_egress_rule_dns" {
  security_group_id = aws_security_group.app_sg.id
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "app_sg_ingress_rule_http" {
  security_group_id            = aws_security_group.app_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Database security group."
  vpc_id      = var.vpc_id
  tags = {
    Name = "db_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "db_sg_egress_rule_mysql" {
  count             = length(var.allowed_mysql_cidrs)
  security_group_id = aws_security_group.db_sg.id
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_ipv4         = element(var.allowed_mysql_cidrs, count.index)
}

resource "aws_vpc_security_group_ingress_rule" "db_sg_ingress_rule_mysql" {
  count             = length(var.allowed_mysql_cidrs)
  security_group_id = aws_security_group.db_sg.id
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_ipv4         = element(var.allowed_mysql_cidrs, count.index)
}
