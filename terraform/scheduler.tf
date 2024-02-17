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
    role_arn = aws_iam_role.aeso_scheduler.arn
    retry_policy {
      maximum_retry_attempts = 0
    }
  }
}


data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "aeso_scheduler" {
  name = "aeso_scheduler"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role.json
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

resource "aws_iam_role_policy_attachment" "aeso_scheduler" {
  role       = aws_iam_role.aeso_scheduler.name
  policy_arn = aws_iam_policy.aeso_scheduler.arn
}
