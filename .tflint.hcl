# TFLint configuration shared by every Terraform directory in the repository.
# pre-commit runs tflint per directory with this file (see
# .pre-commit-config.yaml).
plugin "terraform" {
  enabled = true
  preset  = "recommended"
  version = "0.17.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}
