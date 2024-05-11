resource "aws_iam_user" "local" {
  name = "intermittent-local"
}

resource "aws_iam_access_key" "local" {
  user = aws_iam_user.local.name
}

data "aws_iam_policy_document" "local" {
  statement {
    effect    = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]
    resources = [
      module.ons_sns_sqs.queue_arn["local"],
      module.aeso_sns_sqs.queue_arn["local"],
      module.taipower_sns_sqs.queue_arn["local"]
    ]
  }
}

resource "aws_iam_user_policy" "local" {
  name   = "intermittent-local"
  user   = aws_iam_user.local.name
  policy = data.aws_iam_policy_document.local.json
}
