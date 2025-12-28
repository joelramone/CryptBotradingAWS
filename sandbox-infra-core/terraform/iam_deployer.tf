#############################################
# Terraform Deployer (dev / stg / prod)
# - IAM Role assumed by GitHub Actions (OIDC) / optional root bootstrap
# - IAM Policy for managing infra + PassRole only to runtime roles
#############################################

data "aws_iam_policy_document" "tf_deployer_assume_role" {
  dynamic "statement" {
    for_each = var.enable_trust_root_account ? [1] : []
    content {
      sid     = "TrustRootAccount"
      effect  = "Allow"
      actions = ["sts:AssumeRole"]
      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_trust_github_oidc ? [1] : []
    content {
      sid     = "TrustGitHubOIDC"
      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = [aws_iam_openid_connect_provider.github.arn]
      }

      condition {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:aud"
        values   = ["sts.amazonaws.com"]
      }

      condition {
        test     = "StringLike"
        variable = "token.actions.githubusercontent.com:sub"
        values = [
          for ref in var.github_ref_patterns :
          "repo:${var.github_org}/${var.github_repo}:ref:${ref}"
        ]
      }
    }
  }
}

data "aws_iam_policy_document" "tf_deployer_policy" {
  #############################################
  # Terraform backend: S3 state + DynamoDB lock
  #############################################

  statement {
    sid    = "TerraformStateS3Bucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning"
    ]
    resources = ["arn:aws:s3:::${var.tf_state_bucket}"]
  }

  statement {
    sid    = "TerraformStateS3Objects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObjectVersion",
      "s3:DeleteObjectVersion",
      "s3:PutObjectTagging",
      "s3:GetObjectTagging"
    ]
    resources = ["arn:aws:s3:::${var.tf_state_bucket}/*"]
  }

  statement {
    sid    = "TerraformLockDynamoDB"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem"
    ]
    resources = [aws_dynamodb_table.tf_lock.arn]
  }

  #############################################
  # Deployer permissions (manage infra resources)
  #############################################

  statement {
    sid    = "CloudWatchLogsManage"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DescribeLogGroups",
      "logs:PutRetentionPolicy",
      "logs:TagLogGroup",
      "logs:UntagLogGroup",
      "logs:DescribeLogStreams",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DeleteLogStream"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "LambdaManage"
    effect = "Allow"
    actions = [
      "lambda:CreateFunction",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:DeleteFunction",
      "lambda:ListFunctions",
      "lambda:ListVersionsByFunction",
      "lambda:PublishVersion",
      "lambda:CreateAlias",
      "lambda:UpdateAlias",
      "lambda:DeleteAlias",
      "lambda:GetAlias",
      "lambda:ListAliases",
      "lambda:AddPermission",
      "lambda:RemovePermission",
      "lambda:TagResource",
      "lambda:UntagResource",
      "lambda:ListTags"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "StepFunctionsManage"
    effect = "Allow"
    actions = [
      "states:CreateStateMachine",
      "states:UpdateStateMachine",
      "states:DeleteStateMachine",
      "states:DescribeStateMachine",
      "states:ListStateMachines",
      "states:TagResource",
      "states:UntagResource",
      "states:ListTagsForResource"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SNSManage"
    effect = "Allow"
    actions = [
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:ListTopics",
      "sns:TagResource",
      "sns:UntagResource",
      "sns:ListTagsForResource",
      "sns:Subscribe",
      "sns:Unsubscribe",
      "sns:ListSubscriptions",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SecretsManagerManage"
    effect = "Allow"
    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecret",
      "secretsmanager:TagResource",
      "secretsmanager:UntagResource",
      "secretsmanager:ListSecrets",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRManage"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:BatchGetImage",
      "ecr:BatchDeleteImage",
      "ecr:PutImage",
      "ecr:SetRepositoryPolicy",
      "ecr:GetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
      "ecr:PutLifecyclePolicy",
      "ecr:GetLifecyclePolicy",
      "ecr:DeleteLifecyclePolicy",
      "ecr:TagResource",
      "ecr:UntagResource",
      "ecr:ListTagsForResource"
    ]
    resources = ["*"]
  }

  #############################################
  # 2.2: PassRole ONLY to runtime roles
  #############################################

  statement {
    sid     = "IAMPassRoleRuntimeOnly"
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      aws_iam_role.lambda_base.arn,
      aws_iam_role.sfn_execution.arn
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["lambda.amazonaws.com", "states.amazonaws.com"]
    }
  }

  #############################################
  # Allow Terraform to manage prefixed IAM objects (bootstrap phase)
  #############################################

  statement {
    sid    = "IAMManagePrefixed"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:UpdateRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:ListPolicyVersions",
      "iam:TagPolicy",
      "iam:UntagPolicy"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-${var.environment}-*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.project_name}-${var.environment}-*"
    ]
  }

  statement {
    sid    = "IAMReadList"
    effect = "Allow"
    actions = [
      "iam:ListRoles",
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:GetRole",
      "iam:GetPolicy",
      "iam:GetPolicyVersion"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "terraform_deployer" {
  name               = "${var.project_name}-${var.environment}-terraform-deployer"
  assume_role_policy = data.aws_iam_policy_document.tf_deployer_assume_role.json

  tags = merge(local.tags, {
    Component = "iam"
    Role      = "terraform-deployer"
  })
}

resource "aws_iam_policy" "terraform_deployer" {
  name   = "${var.project_name}-${var.environment}-terraform-deployer-policy"
  policy = data.aws_iam_policy_document.tf_deployer_policy.json

  tags = merge(local.tags, {
    Component = "iam"
    Policy    = "terraform-deployer"
  })
}

resource "aws_iam_role_policy_attachment" "terraform_deployer_attach" {
  role       = aws_iam_role.terraform_deployer.name
  policy_arn = aws_iam_policy.terraform_deployer.arn
}
