resource "aws_scheduler_schedule" "aeso_scheduler" {
  name       = "aeso"
  #group_name = "default"

  flexible_time_window {
    mode = "OFF"
    #maximum_window_in_minutes = 1
  }

  schedule_expression = "rate(1 minute)"

  target {
    arn      = aws_lambda_function.aeso.arn
    role_arn = module.aeso_scheduler_iam.iam_role_arn
    retry_policy {
      maximum_retry_attempts = 0
    }
  }
}


data "aws_iam_policy_document" "aeso_scheduler" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
    ]

    resources = [
    aws_lambda_function.aeso.arn,
    "${aws_lambda_function.aeso.arn}:*",
    ]
  }
}
resource "aws_iam_policy" "aeso_scheduler" {
  name        = "aeso_scheduler"
  path        = "/"
  description = "lambda:InvokeFunction"
  policy      = data.aws_iam_policy_document.aeso_scheduler.json
}


module "aeso_scheduler_iam" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  create_role = true
  role_name         = "aeso_scheduler"
  role_requires_mfa = false
  trusted_role_services = ["scheduler.amazonaws.com"]
  custom_role_policy_arns = [
    aws_iam_policy.aeso_scheduler.arn,
  ]
  trusted_role_actions = ["sts:AssumeRole"]
}
