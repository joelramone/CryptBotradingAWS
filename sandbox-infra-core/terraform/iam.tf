data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_base" {
  name               = "${var.project_name}-${var.environment}-lambda-base"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_base.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_core_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_core" {
  name   = "${var.project_name}-${var.environment}-lambda-core"
  policy = data.aws_iam_policy_document.lambda_core_policy.json
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_core_attach" {
  role       = aws_iam_role.lambda_base.name
  policy_arn = aws_iam_policy.lambda_core.arn
}
