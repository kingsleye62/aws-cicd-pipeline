resource "aws_codebuild_project" "tf_plan" {
  name         = "tf_cicd_plan"
  description  = "Plan stage for terraform"
  service_role = aws_iam_role.tf_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:1.0.8"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential          = var.dockerhub_credentials
      credential_provider = "SECRETS_MANAGER"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/plan-buildspec.yml")
  }

  tags = {
    Environment = "Test"
  }
}



resource "aws_codebuild_project" "tf_apply" {
  name         = "tf_cicd_apply"
  description  = "Apply stage for terraform"
  service_role = aws_iam_role.tf_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:1.0.8"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential          = var.dockerhub_credentials
      credential_provider = "SECRETS_MANAGER"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/apply-buildspec.yml")
  }

  tags = {
    Environment = "Test"
  }
}


resource "aws_codepipeline" "cicd_pipeline" {
  name     = "tf_cicd"
  role_arn = aws_iam_role.tf_code_pipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.code_pipeline_artifacts.id
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["tf_code"]
      configuration = {
        FullRepositoryId     = "kingsleye62/aws-cicd-pipeline"
        BranchName           = "main"
        ConnectionArn        = var.codestar_connector_credentials
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Plan"
    action {
      name            = "Build"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["tf_code"]
      configuration = {
        ProjectName = "tf_cicd_plan"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["tf_code"]
      configuration = {
        ProjectName = "tf_cicd_apply"
      }
    }
  }

}
