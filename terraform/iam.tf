locals {
  envs = ["local","prod"]
}

resource "aws_iam_user" "auth" {
  for_each = toset(local.envs)
  name = "intermittent-${each.key}"
}

resource "aws_iam_access_key" "auth" {
  for_each = toset(local.envs)
  user = aws_iam_user.auth[each.key].name
}

data "aws_iam_policy_document" "auth" {
  for_each = toset(local.envs)
  statement {
    effect    = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]
    resources = [
      module.ons_sns_sqs.queue_arn[each.key],
      module.aeso_sns_sqs.queue_arn[each.key],
      module.taipower_sns_sqs.queue_arn[each.key]
    ]
  }
}

resource "aws_iam_user_policy" "auth" {
  for_each = toset(local.envs)
  name   = "intermittent-${each.key}"
  user   = aws_iam_user.auth[each.key].name
  policy = data.aws_iam_policy_document.auth[each.key].json
}
