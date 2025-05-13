module "label" {
  source      = "cloudposse/label/null"
  version     = "0.25.0"
  label_order = var.label_order
  namespace   = var.namespace
  stage       = var.stage

}
