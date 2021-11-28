resource "aws_iam_role" "codedeploy" {
  name = "${var.app["brand"]}-codedeploy-role"
  description  = "Allows CodeDeploy to call AWS services on your behalf."
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codedeploy.amazonaws.com"
          }
          Sid = ""
        },
      ]
      Version = "2012-10-17"
    }
  )
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole",
  ]
  tags = {}
}

resource "aws_iam_role" "codebuild" {
  name = "${var.app["brand"]}-codebuild-role"
  description = "Allows CodeBuild to call AWS services on your behalf."
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codebuild.amazonaws.com"
          }
          Sid = ""
        },
      ]
      Version = "2012-10-17"
    }
  )
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
  ]
  tags = {}
}


resource "aws_iam_role" "codepipeline" {
  name = "${var.app["brand"]}-codepipeline-role"
  description = "Allows CodePipeline to call AWS services on your behalf."
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codepipeline.amazonaws.com"
          }
          Sid = ""
        },
      ]
      Version = "2012-10-17"
    }
  )
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess",
    "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ]
  tags = {}
}
