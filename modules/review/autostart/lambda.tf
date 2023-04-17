resource "aws_lambda_function" "this" {
  function_name    = var.name
  filename         = data.archive_file.main.output_path
  source_code_hash = data.archive_file.main.output_base64sha256
  role             = aws_iam_role.lambda.arn
  handler          = "index.up"
  runtime          = "nodejs16.x"
  timeout          = 30
  memory_size      = 1024

  environment {
    variables = {
      cluster_arn       = var.cluster_arn,
      service_name      = var.service_name,
      listener_rule_arn = var.listener_rule_arn,
    }
  }
}

resource "aws_lambda_permission" "this" {
  statement_id  = var.name
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.this.arn
}
