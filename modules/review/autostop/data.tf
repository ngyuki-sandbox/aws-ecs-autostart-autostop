data "archive_file" "main" {
  type        = "zip"
  source_file = "${path.module}/../../common/index.js"
  output_path = "${path.module}/../../common/index.zip"
}
