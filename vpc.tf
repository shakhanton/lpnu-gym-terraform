locals {
  network_acls = {
    default_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        protocol   = "all"
        cidr_block = "0.0.0.0/0"
      },
    ]

    private_outbound = [
      {
        rule_number = 90
        rule_action = "deny"
        from_port   = 25
        to_port     = 25
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 91
        rule_action = "deny"
        from_port   = 465
        to_port     = 465
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 92
        rule_action = "deny"
        from_port   = 587
        to_port     = 587
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 93
        rule_action = "deny"
        from_port   = 2525
        to_port     = 2525
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    public_outbound = [
      {
        rule_number = 90
        rule_action = "deny"
        from_port   = 25
        to_port     = 25
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 91
        rule_action = "deny"
        from_port   = 465
        to_port     = 465
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 92
        rule_action = "deny"
        from_port   = 587
        to_port     = 587
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 93
        rule_action = "deny"
        from_port   = 2525
        to_port     = 2525
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
  }
}

module "labels" {
  source      = "cloudposse/label/null"
  version     = "0.25.0"
  context     = var.context
  name        = var.name
  label_order = var.label_order
  environment = var.environment
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"
  name    = module.labels.id
  cidr    = var.vpc_cidr

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  private_dedicated_network_acl = true
  public_dedicated_network_acl  = true

  private_outbound_acl_rules = concat(local.network_acls["default_outbound"], local.network_acls["private_outbound"])
  public_outbound_acl_rules  = concat(local.network_acls["default_outbound"], local.network_acls["private_outbound"])

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = module.labels.tags
}

module "sg_ecs" {
  source = "cloudposse/security-group/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "2.2.0"
  rules = [
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "ingress"
      from_port   = 8001
      to_port     = 8001
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "ingress"
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 65535
      protocol    = "all"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  vpc_id = module.vpc.vpc_id

  context = module.labels.context
  name    = "ecs"
}


module "ecs_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.3.0"
  name        = "ecs"
  description = "Security group for user-service with custom ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8001
      to_port     = 8001
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"              # TODO
      source_security_group_id = var.alb_ecs_service_sg # TODO
    },
  ]
  egress_rules = ["all-all"]
}

module "rds_pg_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.3.0"
  name        = "rds_pg"
  description = "Security group for user-service with custom ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.ecs_sg.security_group_id
    },
  ]
  egress_rules = ["all-all"]
}
