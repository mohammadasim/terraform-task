terraform {
  backend "s3" {
    bucket = "my-first-go-bucket-1060d3a"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
provider "aws" {
  region = "us-east-1"
}
locals {
  vpc_cidr         = "10.0.0.0/16"
  azs              = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  database_subnets = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
  network_acls = {
    public_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 32768
        to_port     = 60999
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ]
    public_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 32768
        to_port     = 60999
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ]
    private_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "udp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = 32768
        to_port     = 60999
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ]
    private_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 53
        to_port     = 53
        protocol    = "udp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = 32768
        to_port     = 60999
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ]
    database_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_block  = "10.0.1.0/24"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_block  = "10.0.2.0/24"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_block  = "10.0.3.0/24"
      }
    ]
    database_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_block  = "10.0.1.0/24"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_block  = "10.0.2.0/24"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_block  = "10.0.3.0/24"
      }
    ]
  }
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.16.0"

  name = "poc-vpc"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnets   = local.database_subnets

  enable_nat_gateway = true
  single_nat_gateway = true


  private_dedicated_network_acl    = true
  create_private_nat_gateway_route = true
  private_inbound_acl_rules        = local.network_acls["private_inbound"]
  private_outbound_acl_rules       = local.network_acls["private_outbound"]

  public_dedicated_network_acl        = true
  create_multiple_public_route_tables = true
  public_inbound_acl_rules            = local.network_acls["public_inbound"]
  public_outbound_acl_rules           = local.network_acls["public_outbound"]

  intra_dedicated_network_acl        = true
  create_multiple_intra_route_tables = true
  intra_inbound_acl_rules            = local.network_acls["database_inbound"]
  intra_outbound_acl_rules           = local.network_acls["database_outbound"]

  tags = {
    Terraform   = "true"
    Environment = "poc"
  }
}

module "app_security_group" {
  source              = "./modules/security-group"
  vpc_id              = module.vpc.vpc_id
  allowed_mysql_cidrs = local.private_subnets
}

module "app_asg" {
  source             = "./modules/autoscaling"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets
  app_sg_id          = module.app_security_group.app_sg_id
  user_data_file     = filebase64("${path.module}/files/userdata.sh")
  alb_sg_id          = module.app_security_group.alb_sg_id
}