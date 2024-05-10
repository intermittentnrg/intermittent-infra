module "aeso" {
  source              = "./modules/harvester"
  name                = "aeso"
  schedule_expression = "rate(1 minute)"
  custom_role_policy_arns = [
    aws_iam_policy.lambda_logging.arn,
  ]
}

module "taipower" {
  source = "./modules/harvester"
  name = "taipower"
  schedule_expression = "rate(10 minutes)"
  custom_role_policy_arns = [
    aws_iam_policy.lambda_logging.arn,
  ]
  providers = {
    aws = aws.hongkong
  }
}


module "orn2" {
  source = "./modules/harvester-s3"
  name = "orn"
  schedule_expression = "rate(1 minute)"
  custom_role_policy_arns = [
    aws_iam_policy.lambda_logging.arn,
  ]
  providers = {
    aws = aws.brazil
  }
}


module "ons_sns_sqs" {
  source = "./modules/harvester-sns-sqs"
  name = "ons-sns-sqs"
  schedule_expression = "rate(1 minute)"
  custom_role_policy_arns = [
    aws_iam_policy.lambda_logging.arn,
  ]
  sqs_queue_names = [
    "github",
    "local",
  ]
  providers = {
    aws = aws.brazil
  }
  github_token = var.github_token
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}
resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging"
  #path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}
