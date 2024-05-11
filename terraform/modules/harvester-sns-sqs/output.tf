output "queue_arn" {
  value = { for s in var.sqs_queue_names : s => module.sqs[s].queue_arn }
}
