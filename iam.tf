resource "aws_iam_role" "tf_code_pipeline_role" {
  name = "tf_code_pipeline_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "codepipeline_role"
  }
}


data "aws_iam_policy_document" "tf_cicd_pipeline_policies" {
  statement {
    sid       = ""
    actions   = ["codestar-connections:UseConnection"]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    sid       = ""
    actions   = ["cloudwatch:*", "s3:*", "codebuild:*"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "tf_cicd_pipeline_policy" {
  name        = "tf_cicd_pipeline_policy"
  path        = "/"
  description = "Pipeline policy"
  policy      = data.aws_iam_policy_document.tf_cicd_pipeline_policies.json
}

resource "aws_iam_role_policy_attachment" "tf_cicd_pipeline_attachment" {
  policy_arn = aws_iam_policy.tf_cicd_pipeline_policy.arn
  role       = aws_iam_role.tf_code_pipeline_role.id
}


resource "aws_iam_role" "tf_codebuild_role" {
  name = "tf_codebuild_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
  tags = {
    tag-key = "tf_codebuild_role"
  }
}

data "aws_iam_policy_document" "tf_cicd_build_policies" {
  statement {
    sid = ""
        actions = ["logs:*", "s3:*", "codebuild:*", "secretsmanager:*","iam:*"]
        resources = ["*"]
        effect = "Allow"
  }
}

resource "aws_iam_policy" "tf_cicd_build_policy" {
  name = "tf_cicd_build_policy"
  path = "/"
  description = "codebuild policy"
  policy = data.aws_iam_policy_document.tf_cicd_build_policies.json
}

resource "aws_iam_role_policy_attachment" "tf_cicd_codebuild_attachment1" {
  policy_arn = aws_iam_policy.tf_cicd_build_policy.arn
  role = aws_iam_role.tf_codebuild_role.id
}

resource "aws_iam_role_policy_attachment" "tf_cicd_codebuild_attachment2" {
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  role = aws_iam_role.tf_codebuild_role.id
}
