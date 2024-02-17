resource "aws_lambda_function" "aeso" {
  filename      = "../aeso.zip"
  function_name = "aeso"
  role          = aws_iam_role.aeso.arn
  handler       = "aeso.handler"
  timeout = 30

  #source_code_hash = data.archive_file.lambda.output_base64sha256
  source_code_hash = filebase64sha256("../aeso.zip")

  runtime = "ruby3.2"
}


data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.aeso.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
