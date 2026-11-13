# Test root for `terraform test`. It holds no resources of its own: every
# run block loads the module under test through `module { source = ... }`.
# Declaring the provider here maps the `proxmox` mock in the test files to
# bpg/proxmox instead of the non-existent hashicorp/proxmox.
terraform {
  required_version = ">= 1.9"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.122"
    }
  }
}
