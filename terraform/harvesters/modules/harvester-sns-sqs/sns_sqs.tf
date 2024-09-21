module "sns" {
  source  = "terraform-aws-modules/sns/aws"
  version = ">= 5.0"

  name = "${var.name}"

  topic_policy_statements = {
    sqs = {
      sid = "SQSSubscribe"
      actions = [
        "sns:Subscribe",
        "sns:Receive",
      ]

      principals = [{
        type        = "AWS"
        identifiers = ["*"]
      }]

      conditions = [{
        test     = "StringLike"
        variable = "sns:Endpoint"
        #values   = [for sqs in module.sqs : sqs.queue_arn]
        values   = values(module.sqs)[*].queue_arn
      }]
    }
  }

  subscriptions = { for s in var.sqs_queue_names :
    s => {
      protocol = "sqs"
      endpoint = module.sqs[s].queue_arn
      raw_message_delivery = true
    }
  }
  # subscriptions = {
  #   sqs = {
  #     protocol = "sqs"
  #     endpoint = { for s in var.sqs_queue_names : s => module.sqs[s].queue_arn }
  #     #endpoint = tolist(values(module.sqs)[*].queue_arn)
  #   }
  # }
}

module "sqs" {
  source = "terraform-aws-modules/sqs/aws"
  for_each = toset(var.sqs_queue_names)

  name = "${var.name}-${each.key}"
  visibility_timeout_seconds = 600
  message_retention_seconds = 1209600
  create_queue_policy = true
  queue_policy_statements = {
    sns = {
      sid     = "SNSPublish"
      actions = ["sqs:SendMessage"]

      principals = [
        {
          type        = "Service"
          identifiers = ["sns.amazonaws.com"]
        }
      ]

      conditions = [{
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = [module.sns.topic_arn]
      }]
    }
  }
}
