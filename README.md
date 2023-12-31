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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_auth0"></a> [auth0](#requirement\_auth0) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | ~> 3.0 |
| <a name="requirement_mongodbatlas"></a> [mongodbatlas](#requirement\_mongodbatlas) | ~> 1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.4.3 |
| <a name="requirement_skopeo2"></a> [skopeo2](#requirement\_skopeo2) | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_auth0"></a> [auth0](#provider\_auth0) | ~> 1.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.24.0 |
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas) | 1.12.3 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backend"></a> [backend](#module\_backend) | ./api | n/a |
| <a name="module_backend-item"></a> [backend-item](#module\_backend-item) | ./api | n/a |
| <a name="module_bathrc-accounts-authorizer"></a> [bathrc-accounts-authorizer](#module\_bathrc-accounts-authorizer) | ./lambda | n/a |
| <a name="module_bathrc-accounts-backend"></a> [bathrc-accounts-backend](#module\_bathrc-accounts-backend) | ./lambda | n/a |
| <a name="module_callback_api"></a> [callback\_api](#module\_callback\_api) | ./api | n/a |
| <a name="module_frontend_bucket"></a> [frontend\_bucket](#module\_frontend\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 3.0 |
| <a name="module_nat"></a> [nat](#module\_nat) | int128/nat-instance/aws | ~> 2.0 |
| <a name="module_ui_api"></a> [ui\_api](#module\_ui\_api) | ./api | n/a |
| <a name="module_ui_item_api"></a> [ui\_item\_api](#module\_ui\_item\_api) | ./api | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [auth0_client.frontend](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/client) | resource |
| [auth0_connection.google](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/connection) | resource |
| [auth0_connection_clients.frontend](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/connection_clients) | resource |
| [auth0_resource_server.backend](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/resource_server) | resource |
| [auth0_resource_server_scopes.backend](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/resource_server_scopes) | resource |
| [auth0_role.admin](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/role) | resource |
| [auth0_role_permissions.admin](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/role_permissions) | resource |
| [aws_api_gateway_authorizer.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_authorizer) | resource |
| [aws_api_gateway_deployment.S3APIDeployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_rest_api.MyS3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.S3APIStage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_api_gateway_usage_plan.S3API](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_instance_profile.private_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.private_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.s3_proxy_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.s3_proxy_role_api_gateway_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.private_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.private_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [mongodbatlas_cluster.default](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cluster) | resource |
| [mongodbatlas_database_user.admin](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user) | resource |
| [mongodbatlas_database_user.application](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/database_user) | resource |
| [mongodbatlas_project_ip_access_list.test](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_access_list) | resource |
| [random_password.mongo_admin_password](https://registry.terraform.io/providers/hashicorp/random/3.4.3/docs/resources/password) | resource |
| [random_password.mongo_application_password](https://registry.terraform.io/providers/hashicorp/random/3.4.3/docs/resources/password) | resource |
| [aws_ami.amazon_linux_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_ecr_authorization_token.dest-ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_authorization_token) | data source |
| [aws_iam_policy_document.api-gateway-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_proxy_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [mongodbatlas_project.default](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth0_client_id"></a> [auth0\_client\_id](#input\_auth0\_client\_id) | n/a | `string` | n/a | yes |
| <a name="input_auth0_client_secret"></a> [auth0\_client\_secret](#input\_auth0\_client\_secret) | n/a | `string` | n/a | yes |
| <a name="input_auth0_domain"></a> [auth0\_domain](#input\_auth0\_domain) | n/a | `string` | n/a | yes |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | These come from the TF cloud variables (https://app.terraform.io/app/bathrc-accounts/workspaces/bathrc-accounts/variables): | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"eu-west-3"` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | n/a | `string` | `"bathrc-accounts"` | no |
| <a name="input_mongo_cluster"></a> [mongo\_cluster](#input\_mongo\_cluster) | n/a | `string` | `"bathrc-accounts"` | no |
| <a name="input_mongo_database"></a> [mongo\_database](#input\_mongo\_database) | n/a | `string` | `"bathrc-accounts"` | no |
| <a name="input_mongo_private_key"></a> [mongo\_private\_key](#input\_mongo\_private\_key) | n/a | `string` | n/a | yes |
| <a name="input_mongo_project"></a> [mongo\_project](#input\_mongo\_project) | n/a | `string` | `"bathrc-accounts"` | no |
| <a name="input_mongo_public_key"></a> [mongo\_public\_key](#input\_mongo\_public\_key) | n/a | `string` | n/a | yes |
| <a name="input_test_instance"></a> [test\_instance](#input\_test\_instance) | n/a | `bool` | `false` | no |
| <a name="input_vpc_subnet_cidr"></a> [vpc\_subnet\_cidr](#input\_vpc\_subnet\_cidr) | n/a | `string` | `"10.106.80.0/21"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apigw-invoke-url"></a> [apigw-invoke-url](#output\_apigw-invoke-url) | n/a |
| <a name="output_private_instance_id"></a> [private\_instance\_id](#output\_private\_instance\_id) | n/a |
| <a name="output_ui-url"></a> [ui-url](#output\_ui-url) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# Automate Terraform with GitHub Actions

This repo is a companion repo to the [Automate Terraform with GitHub Actions tutorial](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions).

# Rest of doc
