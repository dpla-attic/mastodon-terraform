# Terraform for Mastodon

This project uses Terraform to bring up a highly scalable Mastodon instance on a nearly-new AWS account.

This is a WIP and not usable yet.

## Prerequisites

- A registered domain name

- A public Route 53 zone set up with the domain name pointed at it

## Instructions

1. Install Terraform

2. Copy `setup.tf.template` to `setup.tf` and configure the `aws` provider with your account details.

3. Copy `terraform.tfvars.template` to `terraform.tfvars` and configure it to your preferences.

4. Run `terraform plan`

5. Run `terraform apply`