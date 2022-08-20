output "lambda_listener_rule_arn" {
  value = aws_lb_listener_rule.this.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda.arn
}

output "lambda_filename" {
  value = aws_lambda_function.this.filename
}

output "lambda_filehash" {
  value = aws_lambda_function.this.source_code_hash
}
