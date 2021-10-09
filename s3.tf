resource "aws_s3_bucket" "code_pipeline_artifacts" {
  bucket = "pipeline-artifacts-kings"
  acl    = "private"

  tags = {
    Name        = "pipeline-artifacts-kings"
    Environment = "Dev"
  }
}