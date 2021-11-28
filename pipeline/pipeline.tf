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

# # ---------------------------------------------------------------------------------------------------------------------#
# Create EventBridge rule to monitor CodeCommit repository state
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_cloudwatch_event_rule" "codecommit_main" {
  name        = "${var.app["brand"]}-EventBridge-Rule-CodeCommit-Repository-State-Change"
  description = "CloudWatch monitor magento repository state change main branch"
  event_pattern = <<EOF
{
	"source": ["aws.codecommit"],
	"detail-type": ["CodeCommit Repository State Change"],
	"resources": ["${aws_codecommit_repository.app.arn}"],
    "detail": {
     "event": [
       "referenceUpdated"
      ],
		 "referenceType": ["branch"],
		 "referenceName": ["main"]
	}
}
EOF
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Create EventBridge target to execute SSM Document
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_cloudwatch_event_target" "codepipeline_main" {
  rule      = aws_cloudwatch_event_rule.codecommit_main.name
  target_id = "${var.app["brand"]}-EventBridge-Start-CodePipeline"
  arn       = aws_codepipeline.this.arn
  role_arn  = aws_iam_role.eventbridge_service_role.arn
}

resource "aws_codedeploy_app" "this" {
  name = "${var.app["brand"]}-${data.aws_region.current.name}-deployment-app"
  tags = {
    Name = "${var.app["brand"]}-${data.aws_region.current.name}-deployment-app"
  }
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name              = aws_codedeploy_app.this.name
  deployment_group_name = "${var.app["brand"]}-${data.aws_region.current.name}-deployment-group"
  service_role_arn      = aws_iam_role.codedeploy.arn

    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "aws_launch_template.this["admin"].tag_specifications[0].tags.Name"
    }

  trigger_configuration {
    trigger_events     = ["DeploymentFailure","DeploymentSuccess"]
    trigger_name       = "${var.app["brand"]}-${data.aws_region.current.name}-deployment-alert"
    trigger_target_arn = aws_sns_topic.default.arn
  }

  auto_rollback_configuration {
    enabled = false
  }
  
  tags = {
    Name = "${var.app["brand"]}-${data.aws_region.current.name}-deployment-group"
  }
}
