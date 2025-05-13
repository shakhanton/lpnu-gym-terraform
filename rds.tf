# module "db" {
#   source  = "terraform-aws-modules/rds/aws"
#   version = "~> 6.12.0"

#   identifier          = module.labels.id
#   snapshot_identifier = var.rds_snapshot_identifier # Comment if snapshot is unavailable

#   engine            = "postgres"
#   engine_version    = "10.18"
#   instance_class    = var.rds_instance_class #"db.t2.micro"
#   allocated_storage = 100
#   storage_encrypted = false
#   storage_type      = "gp2"
#   iops              = 0

#   name     = jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["RDS_DB_NAME"]
#   username = jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["RDS_USERNAME"]
#   password = jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["RDS_PASSWORD"]
#   port     = jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["RDS_PORT"]

#   iam_database_authentication_enabled = false

#   vpc_security_group_ids = var.sg_rds_id

#   maintenance_window = "sun:08:20-sun:08:50"
#   backup_window      = "07:32-08:02"

#   # Enhanced Monitoring - see example for details on how to create the role
#   # by yourself, in case you don't want to create it automatically
#   monitoring_interval    = "30"
#   monitoring_role_name   = "${module.labels.id}-RDSMonitoring"
#   create_monitoring_role = true

#   tags = module.labels.tags
#   # DB subnet group
#   subnet_ids = var.private_subnets_ids

#   # DB parameter group
#   family                          = "postgres10"
#   parameter_group_name            = module.labels.id
#   parameter_group_use_name_prefix = true
#   # create_db_parameter_group       = false

#   # DB option group
#   major_engine_version        = "10"
#   allow_major_version_upgrade = true

#   # Database Deletion Protection
#   deletion_protection = true

# }
