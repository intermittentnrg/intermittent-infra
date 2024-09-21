resource "aws_lambda_function" "this" {
  filename      = "../${var.name}.zip"
  function_name = var.name
  role          = module.iam.iam_role_arn
  handler       = "${var.name}.handler"
  timeout       = 30

  source_code_hash = filebase64sha256("../${var.name}.zip")

  runtime = "ruby3.2"
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:PutItem",
    ]

    resources = [aws_dynamodb_table.this.arn]
  }
}
resource "aws_iam_policy" "this" {
  name = var.name
  #path        = "/"
  description = "dynamodb:PutItem"
  policy      = data.aws_iam_policy_document.this.json
}


module "iam" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  create_role           = true
  role_name             = var.name
  role_requires_mfa     = false
  trusted_role_services = ["lambda.amazonaws.com"]
  custom_role_policy_arns = concat([
    aws_iam_policy.this.arn,
  ], var.custom_role_policy_arns)
  trusted_role_actions = ["sts:AssumeRole"]
}
