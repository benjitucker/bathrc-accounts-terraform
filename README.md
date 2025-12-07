# Table of Contents

<!-- Line above is skipped in pre-commit md-toc -->
<!--TOC-->

- [precommit](#precommit)
- [terraform-doc](#terraform-doc)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [Automate Terraform with GitHub Actions](#automate-terraform-with-github-actions)
- [Rest of doc](#rest-of-doc)

<!--TOC-->

# precommit

This terraform module utilised [pre-commit](https://pre-commit.com/). You can install the git hooks locally to aid you with ensuring that the terraform module complies with our linting, formatting, security and validation policies. Once pre-commit is installed on you development machine you can run:

``` bash
$ pre-commit install
$ pre-commit run --all-files
$
```

The checks will also be performed automatically by pre-commit when attempting to git commit.

# terraform-doc

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | ~> 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.0 |
| <a name="requirement_skopeo2"></a> [skopeo2](#requirement\_skopeo2) | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.24.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bathrc-accounts-backend"></a> [bathrc-accounts-backend](#module\_bathrc-accounts-backend) | ./lambda | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_ecr_authorization_token.dest-ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_authorization_token) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | These come from the TF cloud variables (https://app.terraform.io/app/bathrc-accounts/workspaces/bathrc-accounts/variables): | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"eu-west-3"` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | n/a | `string` | `"bathrc-accounts"` | no |
| <a name="input_vpc_subnet_cidr"></a> [vpc\_subnet\_cidr](#input\_vpc\_subnet\_cidr) | n/a | `string` | `"10.106.80.0/21"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

# Automate Terraform with GitHub Actions

This repo is a companion repo to the [Automate Terraform with GitHub Actions tutorial](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions).

# Rest of doc
