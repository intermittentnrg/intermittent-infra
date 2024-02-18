resource "aws_lambda_function" "aeso" {
  filename      = "../aeso.zip"
  function_name = "aeso"
  role          = module.aeso_iam.iam_role_arn
  handler       = "aeso.handler"
  timeout = 30

  #source_code_hash = data.archive_file.lambda.output_base64sha256
  source_code_hash = filebase64sha256("../aeso.zip")

  runtime = "ruby3.2"
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
  name        = "lambda_logging"
  #path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}


data "aws_iam_policy_document" "aeso" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:PutItem",
    ]

    resources = [aws_dynamodb_table.aeso.arn]
  }
}
resource "aws_iam_policy" "aeso" {
  name        = "aeso"
  #path        = "/"
  description = "dynamodb:PutItem"
  policy      = data.aws_iam_policy_document.aeso.json
}


module "aeso_iam" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  create_role = true
  role_name         = "aeso"
  role_requires_mfa = false
  trusted_role_services = ["lambda.amazonaws.com"]
  custom_role_policy_arns = [
    aws_iam_policy.aeso.arn,
    aws_iam_policy.lambda_logging.arn,
  ]
  trusted_role_actions = ["sts:AssumeRole"]
}
