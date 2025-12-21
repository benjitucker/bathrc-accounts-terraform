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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | ~> 3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.0 |
| <a name="requirement_skopeo2"></a> [skopeo2](#requirement\_skopeo2) | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.25.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bathrc-accounts-backend"></a> [bathrc-accounts-backend](#module\_bathrc-accounts-backend) | ./lambda | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.basic-dynamodb-table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_security_group.ses_vpc_endpoint_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ssm_vpc_endpoint_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ses_domain_dkim.bathridingclub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_dkim) | resource |
| [aws_ses_domain_identity.bathridingclub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity) | resource |
| [aws_ses_email_identity.training_email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_email_identity) | resource |
| [aws_ssm_parameter.jotform-apikey](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_vpc_endpoint.dynamodb_vpce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ses](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_ecr_authorization_token.dest-ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_authorization_token) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | These come from the TF cloud variables (https://app.terraform.io/app/benjitucker-bathrc/workspaces/bathrc-accounts/variables): | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"eu-west-3"` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | n/a | `string` | `"bathrc-accounts"` | no |
| <a name="input_github_pat"></a> [github\_pat](#input\_github\_pat) | n/a | `string` | n/a | yes |
| <a name="input_jotform_apikey"></a> [jotform\_apikey](#input\_jotform\_apikey) | n/a | `string` | n/a | yes |
| <a name="input_vpc_subnet_cidr"></a> [vpc\_subnet\_cidr](#input\_vpc\_subnet\_cidr) | n/a | `string` | `"10.106.80.0/21"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_jotform_webhook_url"></a> [jotform\_webhook\_url](#output\_jotform\_webhook\_url) | n/a |
| <a name="output_ses_dkim_tokens"></a> [ses\_dkim\_tokens](#output\_ses\_dkim\_tokens) | ses\_dkim\_tokens → 3 CNAME records for DKIM. |
| <a name="output_ses_verification_token"></a> [ses\_verification\_token](#output\_ses\_verification\_token) | ses\_verification\_token → TXT record in 123-reg for domain verification. |
<!-- END_TF_DOCS -->

# Automate Terraform with GitHub Actions

This repo is a companion repo to the [Automate Terraform with GitHub Actions tutorial](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions).

# Rest of doc
