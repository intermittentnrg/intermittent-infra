variable "name" {}
variable "custom_role_policy_arns" {}
variable "schedule_expression" {}
variable "sqs_queue_names" {
  type    = list(string)
}
variable "github_token" {}
