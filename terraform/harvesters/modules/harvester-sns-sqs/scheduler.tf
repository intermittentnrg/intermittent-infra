resource "aws_scheduler_schedule" "scheduler" {
  name = var.name

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(1 minute)"

  target {
    arn      = aws_lambda_function.this.arn
    role_arn = module.scheduler_iam.iam_role_arn
    retry_policy {
      maximum_retry_attempts = 0
    }
  }
}


data "aws_iam_policy_document" "scheduler" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
    ]

    resources = [
      aws_lambda_function.this.arn,
      "${aws_lambda_function.this.arn}:*",
    ]
  }
}
resource "aws_iam_policy" "scheduler" {
  name        = "${var.name}_scheduler"
  path        = "/"
  description = "lambda:InvokeFunction"
  policy      = data.aws_iam_policy_document.scheduler.json
}


module "scheduler_iam" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  create_role           = true
  role_name             = "${var.name}_scheduler"
  role_requires_mfa     = false
  trusted_role_services = ["scheduler.amazonaws.com"]
  custom_role_policy_arns = [
    aws_iam_policy.scheduler.arn,
  ]
  trusted_role_actions = ["sts:AssumeRole"]
}
