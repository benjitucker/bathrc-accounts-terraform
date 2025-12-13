config {
  call_module_type    = "all"
  force               = false
  disabled_by_default = false
}

plugin "aws" {
  enabled = true
  region  = "us-west-2"
  version = "0.37.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Let dev follow master
rule "terraform_module_pinned_source" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}

rule "terraform_required_version" {
  enabled = false
}

# Unused declarations are disabled because they include unused input variables and if input variables are removed then
# module becomes incompatible leading to the inability to deploy infrastructure hotfix to existing environment
rule "terraform_unused_declarations" {
  enabled = false
}

# The old style splat operator is used extensively throughout the code which relies on its specific behaviour. A rework
# will be needed to remove the use of splat.
rule "terraform_deprecated_index" {
  enabled = false
}
