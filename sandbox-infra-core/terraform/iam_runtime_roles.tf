locals {
  runtime_role_prefix = "${var.project}-${var.env}"
}

#############################################
# LAMBDA EXECUTION ROLE (runtime)
#############################################

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_execution" {
  name               = "${local.runtime_role_prefix}-lambda-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json

  tags = merge(local.common_tags, {
    Component = "iam"
    Role      = "lambda-execution"
  })
}

data "aws_iam_policy_document" "lambda_execution_policy" {
  statement {
    sid    = "CloudWatchLogsWrite"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ReadSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ReadSSM"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DynamoDBRW"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "SNSPublish"
    effect  = "Allow"
    actions = ["sns:Publish"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_execution" {
  name   = "${local.runtime_role_prefix}-lambda-exec-policy"
  policy = data.aws_iam_policy_document.lambda_execution_policy.json

  tags = merge(local.common_tags, {
    Component = "iam"
    Policy    = "lambda-execution"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_attach" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_execution.arn
}

#############################################
# STEP FUNCTIONS EXECUTION ROLE (runtime)
#############################################

data "aws_iam_policy_document" "sfn_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sfn_execution" {
  name               = "${local.runtime_role_prefix}-sfn-exec"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume.json

  tags = merge(local.common_tags, {
    Component = "iam"
    Role      = "sfn-execution"
  })
}

data "aws_iam_policy_document" "sfn_execution_policy" {
  statement {
    sid    = "InvokeProjectLambdas"
    effect = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = [
      "arn:aws:lambda:${var.region}:${var.aws_account_id}:function:${var.project}-${var.env}-*"
    ]
  }

  statement {
    sid     = "SNSPublish"
    effect  = "Allow"
    actions = ["sns:Publish"]
    resources = ["*"]
  }

  statement {
    sid    = "CloudWatchLogsDelivery"
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "sfn_execution" {
  name   = "${local.runtime_role_prefix}-sfn-exec-policy"
  policy = data.aws_iam_policy_document.sfn_execution_policy.json

  tags = merge(local.common_tags, {
    Component = "iam"
    Policy    = "sfn-execution"
  })
}

resource "aws_iam_role_policy_attachment" "sfn_execution_attach" {
  role       = aws_iam_role.sfn_execution.name
  policy_arn = aws_iam_policy.sfn_execution.arn
}
