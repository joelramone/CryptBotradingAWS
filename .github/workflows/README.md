NEXT STEP NOTES (CI/CD secrets)
Add these GitHub repo secrets:

AWS_REGION                      (e.g. us-east-1)
AWS_TERRAFORM_DEPLOYER_ROLE_ARN  (arn of terraform-deployer role for the target account)
TF_STATE_BUCKET                 (same bucket used for terraform state)
TF_LOCK_TABLE                   (same dynamodb lock table)
TF_STATE_PREFIX                 (optional; default "states")

State keys convention:
states/<env>/<sandbox>/terraform.tfstate
states/<env>/sandbox-infra-core/terraform.tfstate
