output "test" {
  value = values(module.sqs)[*].queue_arn
}
