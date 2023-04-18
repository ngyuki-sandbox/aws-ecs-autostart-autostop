resource "aws_lambda_function" "down" {
  function_name    = "${var.name}-down"
  filename         = data.archive_file.main.output_path
  source_code_hash = data.archive_file.main.output_base64sha256
  role             = aws_iam_role.lambda.arn
  handler          = "index.down"
  runtime          = "nodejs16.x"
  timeout          = 30
  memory_size      = 1024

  environment {
    variables = {
      parameter_prefix = var.parameter_prefix
    }
  }
}
