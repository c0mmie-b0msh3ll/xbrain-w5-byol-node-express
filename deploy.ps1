param(
  [string]$Region = 'us-west-2',
  [string]$StackName = 'byol-node-express'
)

$ErrorActionPreference = 'Stop'

$accountId = aws sts get-caller-identity --query Account --output text
$artifactBucket = "$StackName-artifacts-$accountId-$Region".ToLower()

aws s3api head-bucket --bucket $artifactBucket 2>$null
if ($LASTEXITCODE -ne 0) {
  aws s3api create-bucket `
    --bucket $artifactBucket `
    --region $Region `
    --create-bucket-configuration LocationConstraint=$Region | Out-Null
}

aws cloudformation package `
  --template-file template.yaml `
  --s3-bucket $artifactBucket `
  --output-template-file packaged.yaml

aws cloudformation deploy `
  --template-file packaged.yaml `
  --stack-name $StackName `
  --region $Region `
  --capabilities CAPABILITY_IAM `
  --no-fail-on-empty-changeset

$apiUrl = aws cloudformation describe-stacks `
  --stack-name $StackName `
  --region $Region `
  --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" `
  --output text

Write-Host "Deployed: $apiUrl"
