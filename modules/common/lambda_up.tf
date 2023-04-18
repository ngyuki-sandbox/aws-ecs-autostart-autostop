resource "aws_lambda_function" "main" {
  function_name    = "${var.name}-up"
  filename         = data.archive_file.main.output_path
  source_code_hash = data.archive_file.main.output_base64sha256
  role             = aws_iam_role.lambda.arn
  handler          = "index.up"
  runtime          = "nodejs16.x"
  timeout          = 30
  memory_size      = 1024

  environment {
    variables = {
      parameter_prefix = var.parameter_prefix
    }
  }
}

resource "aws_lambda_permission" "main" {
  statement_id  = var.name
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.lambda.arn
}
