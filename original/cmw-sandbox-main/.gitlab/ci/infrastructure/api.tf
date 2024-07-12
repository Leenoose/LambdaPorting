locals {
  application_name = "scoot-${var.environment}-${var.app_name}"
  application_prefix = "${var.app_name}-"
}

resource "aws_ecr_repository" "api" {
  name                 = local.application_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_lifecycle_policy" "cleanup_policy" {
  repository = aws_ecr_repository.api.name

  policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Expire ${local.application_name}",
        "selection" : {
        "tagStatus" : "tagged",
        "tagPrefixList" : ["${local.application_prefix}"]
        "countType" : "imageCountMoreThan",
        "countNumber" : 5
        },
        "action" : {
            "type" : "expire"
        }
      }
    ]
  })
}


resource "aws_iam_role" "api" {
  name = local.application_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })

  inline_policy {
    name = "${local.application_name}-ssm-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:GetParameters",
            "ssm:GetParametersByPath",
            "ssm:GetParameter",
            "ssm:PutParameter"
          ]
          Effect   = "Allow"
          Sid      = ""
          Resource = "*"
        },
        {
          Action   = "kms:Decrypt"
          Effect   = "Allow"
          Sid      = ""
          Resource = "*"
        },
        {
          Action = [
            "ec2:DescribeNetworkInterfaces",
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeInstances",
            "ec2:AttachNetworkInterface"
          ]
          Effect   = "Allow"
          Sid      = ""
          Resource = "*"
        },
        {
          Action   = ["events:PutEvents"],
          Effect   = "Allow"
          Sid      = ""
          Resource = "*"
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect   = "Allow"
          Sid      = ""
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_kms_key" "api" {
  description         = "KMS Key for ${local.application_name}"
  enable_key_rotation = true
}

resource "aws_kms_alias" "a" {
  name          = "alias/${local.application_name}"
  target_key_id = aws_kms_key.api.key_id
}

resource "aws_iam_role_policy_attachment" "api" {
  role       = aws_iam_role.api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

### BOOKING GATEWAY RESOURCE  ########################
data "aws_api_gateway_rest_api" "parent" {
  name = var.parent_gateway_name
}

data "aws_api_gateway_resource" "v1" {
  rest_api_id = data.aws_api_gateway_rest_api.parent.id
  path        = "/v1"
}

resource "aws_api_gateway_resource" "dashboard" {
  rest_api_id = data.aws_api_gateway_rest_api.parent.id
  parent_id   = data.aws_api_gateway_resource.v1.id
  path_part   = "items"
}