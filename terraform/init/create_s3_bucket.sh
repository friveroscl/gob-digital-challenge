#!/bin/bash

BUCKET_NAME=$1
REGION=$2

if [[ -z "$BUCKET_NAME" || -z "$REGION" ]]; then
  echo "Usage: $0 <bucket-name> <aws-region>"
  exit 1
fi

if [[ "$REGION" == "us-east-1" ]]; then
  aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
else
  aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION"
fi

aws s3api wait bucket-exists --bucket "$BUCKET_NAME"

aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled

echo "S3 bucket '$BUCKET_NAME' created successfully with versioning enabled."
