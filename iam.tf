
resource "aws_iam_role" "ECSTaskExecutionRole" {
  name = "${module.labels.id}-ECSTExecRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "ECSTaskExecutionRole" {
  role       = aws_iam_role.ECSTaskExecutionRole.name
  policy_arn = aws_iam_policy.ECSTaskExecutionRole.arn
}

resource "aws_iam_policy" "ECSTaskExecutionRole" {
  name   = module.labels.id
  path   = "/"
  policy = data.aws_iam_policy_document.ECSTaskExecutionRole.json
}


data "aws_iam_policy_document" "ECSTaskExecutionRole" {
  statement {
    actions = [
      "kms:Decrypt",
    ]

    resources = [
      "*",
    ]
  }

#   statement {
#     actions = [
#       "secretsmanager:Describe*",
#       "secretsmanager:Get*",
#       "secretsmanager:List*",
#     ]

#     resources = [
#       data.terraform_remote_state.secrets.outputs.django_arn,
#       data.terraform_remote_state.secrets.outputs.rds_arn,
#       data.terraform_remote_state.secrets.outputs.aws_arn,
#     ]
#   }
  statement {
    actions = [
      "secretsmanager:ListSecrets"
    ]

    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "ecr:*",
    ]

    resources = [
      module.ecr.repository_arn,
    ]
  }
  statement {
    actions = [
      "ecr:Describe*",
      "ecr:Get*",
    ]

    resources = [
      "*"
    ]
  }
  # statement {
  #   actions = [
  #     "logs:*"
  #   ]
  #
  #   resources = [
  #
  #   ]
  # }
}

resource "aws_iam_role" "ECSTaskRole" {
  name = "${module.labels.id}-ECSTaskRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = module.labels.tags
}

### TODO
resource "aws_iam_role_policy_attachment" "ECSTaskRole" {
  role       = aws_iam_role.ECSTaskRole.name
  policy_arn = aws_iam_policy.ECSTaskExecutionRole.arn
}
