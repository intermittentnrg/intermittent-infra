module "aeso" {
  source              = "./modules/harvester"
  name                = "aeso"
  schedule_expression = "rate(1 minute)"
  custom_role_policy_arns = [
    aws_iam_policy.lambda_logging.arn,
  ]
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
