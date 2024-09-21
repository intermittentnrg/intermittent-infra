output "queue_arn" {
  value = { for s in var.sqs_queue_names : s => module.sqs[s].queue_arn }
}
output "queue_url" {
  value = { for s in var.sqs_queue_names : s => module.sqs[s].queue_url }
}
