module "label_ecs" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.label.context
  name    = "fastapi"
}

module "ecs_cluster" {
  source  = "cloudposse/ecs-cluster/aws"
  version = "0.9.0"
  name    = module.label_ecs.id

  container_insights_enabled = false
  capacity_providers_fargate = true
}
