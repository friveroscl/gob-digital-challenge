#!/bin/bash

REGION=$1

if [[ -z "$REGION" ]]; then
  echo "Usage: $0 <aws-region>"
  exit 1
fi

aws dynamodb create-table \
    --table-name terraform-lock \
    --billing-mode PAY_PER_REQUEST \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --tags Key=Name,Value=terraform-lock \
    --region $REGION
