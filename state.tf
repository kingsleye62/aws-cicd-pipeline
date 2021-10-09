terraform {
  backend "s3" {
        bucket = "king-aws-cicd-pipiline"
        encrypt = true
        key = "terraform.tfstate"
        region = "us-east-1"
        # role_arn = "arn:aws:iam::409592171686:role/terraform-aws-role"
        access_key = "AKIAV6XMYRSTFVBM5TCL"
        secret_key = "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"
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "AKIAV6XMYRSTFVBM5TCL"
  secret_key = "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"
}