# Aws Cost Notifier

Daily slack notifications of AWS monthly costs.

## Overview

This application automatically notifies your Slack channel about AWS monthly costs on a daily basis, helping you track and monitor your AWS spending efficiently.

## Prerequisites

- Go 1.21.7 or later
- Terraform 1.9.8 or later
- AWS CLI 2.19.1 or later
- Docker (for Lambda container image)
- AWS Account with appropriate permissions

## Setup

### 1. Configure AWS Profile

```bash
export AWS_PROFILE={YOUR_PROFILE}
```

### 2. Configure Slack Webhook

Store your Slack webhook URL in AWS Parameter Store.

Parameter name: SLACK_WEBHOOK_URL_COST_NOTIFIER
Type: SecureString
Value: Your Slack webhook URL

## Deployment

```bash
cd infra
```

### Initialize Terraform (First time only)

```bash
terraform init
```

### Preview Changes

```bash
terraform plan -var-file=terraform.tfvars.{env}
```

### Apply Changes

```bash
terraform apply -var-file=terraform.tfvars.{env}
```

Replace {env} with your target environment (stg/prod)
