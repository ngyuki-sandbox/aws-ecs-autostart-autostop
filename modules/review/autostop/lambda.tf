resource "aws_lambda_function" "this" {
  function_name    = var.name
  filename         = var.lambda_filename
  source_code_hash = var.lambda_filehash
  role             = var.lambda_role_arn
  handler          = "index.down"
  runtime          = "nodejs16.x"
  timeout          = 30
  memory_size      = 1024
}

resource "aws_lambda_permission" "this" {
  statement_id  = var.name
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.this.arn
}
