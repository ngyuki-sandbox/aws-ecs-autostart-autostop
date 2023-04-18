data "archive_file" "main" {
  type        = "zip"
  source_file = "${path.module}/index.js"
  output_path = "${path.module}/index.zip"
}
