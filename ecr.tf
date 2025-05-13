module "label_ecr" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.label.context
  name    = "fastapi"
}

module "ecr" {
  source  = "cloudposse/ecr/aws"
  version = "0.42.1"
  name    = module.label_ecr.id
  max_image_count = var.max_image_count
}
