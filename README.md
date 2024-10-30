# Terraform AWS Setup

This repository contains a Terraform configuration for deploying resources to AWS. Follow these instructions to set up your environment and begin using Terraform to manage AWS infrastructure.

## Prerequisites

Ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/) and configured with your AWS credentials
- An AWS account with permissions to create resources as defined in `main.tf`

## Setup Instructions

### Step 1: Clone the Repository

Clone this repository to your local environment.

```bash
git clone https://github.com/ngetichnicholas/Terraform.git
cd Terraform
```

### Step 2: Configure AWS Credentials

To use AWS with Terraform, you need to set up your AWS credentials. You can do this using the AWS CLI by running:

```bash
aws configure
```

This will prompt you to enter your:

- AWS Access Key
- AWS Secret Key
- Default Region
- Default Output Format

Your credentials will be stored in `~/.aws/credentials` on Linux/MacOS or `C:\Users\YourUsername\.aws\credentials` on Windows.

Alternatively, you can set credentials using environment variables:

```bash
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
export AWS_DEFAULT_REGION="your_region"
```

### Step 3: Initialize Terraform

Initialize Terraform to download the required provider plugins specified in `main.tf`.

```bash
terraform init
```

### Step 4: Review the Plan

Use the `terraform plan` command to review the resources that will be created or modified according to the configuration:

```bash
terraform plan
```

This provides a preview of changes without applying them.

### Step 5: Apply the Configuration

To apply the configuration and create/update resources on AWS, run:

```bash
terraform apply
```

Terraform will prompt for confirmation. Type `yes` to proceed.

### Step 6: Manage Terraform State

Terraform keeps track of your resources in a `terraform.tfstate` file. Be careful with this file as it reflects the current state of your infrastructure.

To view the current state, use:

```bash
terraform show
```

### Step 7: Destroy Infrastructure (Optional)

To remove all resources defined in your configuration, use the following command:

```bash
terraform destroy
```

Terraform will prompt for confirmation before deleting resources.