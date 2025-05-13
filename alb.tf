module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.16.0"

  name = "${module.labels.id}-alb"

  load_balancer_type = "application"

  vpc_id          = module.vpc.default_vpc_id
  subnets         = module.vpc.public_subnets_ids
  security_groups = split(",", module.ecs_service_sg.security_group_id)

  access_logs = {
    bucket = module.s3_alb_logs.s3_bucket_id
  }

  target_groups = [
    {
      name_prefix      = "ecs-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      health_check = {
        enabled             = true
        interval            = 35 # The range is 5–300 seconds. The default is 30 seconds
        path                = "/"
        port                = "8000"
        healthy_threshold   = 5  # The range is 2–10. The default is 5.
        unhealthy_threshold = 2  # The range is 2–10. The default is 2.
        timeout             = 30 # The range is 2–120 seconds. The default is 5 seconds if the target type is instance or ip.
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

#   https_listeners = [
#     {
#       port               = 443
#       protocol           = "HTTPS"
#       certificate_arn    = var.alb_acm_arn
#       target_group_index = 0
#     }
#   ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      action_type        = "forward"
      # action_type        = "redirect"
      # redirect = {
      #   port        = "443"
      #   protocol    = "HTTPS"
      #   status_code = "HTTP_301"
      # }
    }
  ]
  tags = module.labels.tags
}