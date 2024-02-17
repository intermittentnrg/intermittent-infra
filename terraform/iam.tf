data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "aeso" {
  name = "aeso"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
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
  path        = "/"
  description = "dynamodb:PutItem"
  policy      = data.aws_iam_policy_document.aeso.json
}

resource "aws_iam_role_policy_attachment" "aeso" {
  role       = aws_iam_role.aeso.name
  policy_arn = aws_iam_policy.aeso.arn
}
