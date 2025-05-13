
data "aws_region" "current" {}
module "label_ecs" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.label.context
  name    = "fastapi"
}

module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.12.1"

  cluster_name = module.labels.id

  # container_insights = false

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = module.labels.tags
}


resource "aws_ecs_service" "api" {
  name            = "api"
  cluster         = module.ecs_cluster.ecs_cluster_id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = module.alb.target_groups[0]
    container_name   = "api"
    container_port   = 8000
  }

  network_configuration {
    subnets          = module.vpc.public_subnets[0]
    security_groups  = module.ecs_sg.security_group_id
    assign_public_ip = true
  }
  health_check_grace_period_seconds = 0
  platform_version                  = "LATEST"
  propagate_tags                    = "SERVICE"
  tags                              = module.labels.tags
  deployment_controller {
    type = "ECS"
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = "1"
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${module.labels.id}-api"
  container_definitions    = module.container_api.json_map_encoded_list
  execution_role_arn       = aws_iam_role.ECSTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ECSTaskRole.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "2048"
  memory                   = "8192"
}

module "container_api" {
  source           = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition?ref=0.61.2"
  container_name   = "api"
  container_cpu    = "256"
  container_memory = "512"
  container_image  = "${module.ecr_django_app.repository_url}:${var.container_api_tag}"

  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-region"        = data.aws_region.current.name
      "awslogs-group"         = "${module.labels.id}-api"
      "awslogs-stream-prefix" = "api"
    }
  }

  environment = [
    {
      name  = "DEBUG"
      value = "True"
    }
  ]
}
