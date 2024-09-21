resource "github_actions_secret" "aws_id" {
  repository       = "intermittent-${var.name}"
  secret_name      = "AWS_ACCESS_KEY_ID"
  plaintext_value  = aws_iam_access_key.github.id
}

resource "github_actions_secret" "aws_secret" {
  repository       = "intermittent-${var.name}"
  secret_name      = "AWS_SECRET_ACCESS_KEY"
  plaintext_value  = aws_iam_access_key.github.secret
}

resource "github_actions_secret" "queue_url" {
  repository       = "intermittent-${var.name}"
  secret_name      = "QUEUE_URL"
  plaintext_value  = module.sqs["github"].queue_url
}


resource "aws_iam_user" "github" {
  name = "${var.name}"
}

resource "aws_iam_access_key" "github" {
  user = aws_iam_user.github.name
}

data "aws_iam_policy_document" "github" {
  statement {
    effect    = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]
    resources = [module.sqs["github"].queue_arn]
  }
}

resource "aws_iam_user_policy" "github" {
  name   = var.name
  user   = aws_iam_user.github.name
  policy = data.aws_iam_policy_document.github.json
}
