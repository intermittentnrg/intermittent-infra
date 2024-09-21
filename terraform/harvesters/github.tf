resource "aws_iam_user" "github" {
  name = "intermittent-data"
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
    resources = [
      module.ons_sns_sqs.queue_arn["cloud"],
      module.taipower_sns_sqs.queue_arn["cloud"],
      module.aeso_sns_sqs.queue_arn["cloud"]
    ]
  }
}

resource "aws_iam_user_policy" "github" {
  name   = "intermittent-data"
  user   = aws_iam_user.github.name
  policy = data.aws_iam_policy_document.github.json
}

resource "github_actions_environment_secret" "aws_id" {
  repository       = "intermittent-data"
  environment      = "production"
  secret_name      = "AWS_ACCESS_KEY_ID"
  plaintext_value  = aws_iam_access_key.github.id
}

resource "github_actions_environment_secret" "aws_secret" {
  repository       = "intermittent-data"
  environment      = "production"
  secret_name      = "AWS_SECRET_ACCESS_KEY"
  plaintext_value  = aws_iam_access_key.github.secret
}

resource "github_actions_environment_secret" "aeso_queue_url" {
  repository       = "intermittent-data"
  environment      = "production"
  secret_name      = "AESO_QUEUE_URL"
  plaintext_value  = module.aeso_sns_sqs.queue_url["cloud"]
}

resource "github_actions_environment_secret" "ons_queue_url" {
  repository       = "intermittent-data"
  environment      = "production"
  secret_name      = "ONS_QUEUE_URL"
  plaintext_value  = module.ons_sns_sqs.queue_url["cloud"]
}

resource "github_actions_environment_secret" "taipower_queue_url" {
  repository       = "intermittent-data"
  environment      = "production"
  secret_name      = "TAIPOWER_QUEUE_URL"
  plaintext_value  = module.taipower_sns_sqs.queue_url["cloud"]
}
