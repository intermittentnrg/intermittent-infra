data "archive_file" "this" {
  type        = "zip"
  source_file = "../${var.name}.rb"
  output_path = "../${var.name}.zip"
}

resource "aws_lambda_function" "this" {
  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256
  function_name    = var.name
  role             = module.iam.iam_role_arn
  handler          = "${var.name}.handler"
  timeout          = 30

  environment {
    variables = {
      SNS_TOPIC = module.sns.topic_arn
    }
  }

  runtime = "ruby3.2"
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    actions = [
      "sns:Publish",
    ]

    resources = [module.sns.topic_arn]
  }
}
resource "aws_iam_policy" "this" {
  name = var.name
  #path        = "/"
  description = ""
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
