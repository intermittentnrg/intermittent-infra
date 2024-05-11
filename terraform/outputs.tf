output "taipower_sqs_queue_url" {
  value = module.sqs.queue_url
}

output "env" {
  value = {for s in local.envs :
    s => {
      "AESO_QUEUE_URL" = module.aeso_sns_sqs.queue_url[s],
      "ONS_QUEUE_URL" = module.ons_sns_sqs.queue_url[s],
      "TAIPOWER_QUEUE_URL" = module.taipower_sns_sqs.queue_url[s],
    }
  }
}

output  "secrets" {
  value = {for s in local.envs :
    s => {
      "AWS_ACCESS_KEY_ID" = aws_iam_access_key.auth[s].id
      "AWS_SECRET_ACCESS_KEY" = aws_iam_access_key.auth[s].secret
    }
  }
  sensitive = true
}
