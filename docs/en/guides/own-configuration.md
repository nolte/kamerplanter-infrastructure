---
title: Use the modules in your configuration
audience: [terraform-author]
content_mode: how-to
track: developer-docs
last_updated: 2026-11-13
---

# Use the modules in your configuration

The example in `src/scripts/proxmox` covers the common case. If you already manage your Proxmox VE node with Terraform or OpenTofu, call the two modules from your own configuration instead.

## Reference the modules

Load the modules straight from GitHub and pin `ref` to a release tag, never to a branch:

```hcl
terraform {
  required_version = ">= 1.9"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.122"
    }
  }
}

provider "proxmox" {}   # reads PROXMOX_VE_ENDPOINT and PROXMOX_VE_API_TOKEN

module "image" {
  source = "github.com/nolte/kamerplanter-infrastructure//src/modules/proxmox-appliance-image?ref=v0.1.0"

  node_name = "pve"
  image_url = "https://github.com/nolte/kamerplanter-appliance/releases/download/v0.1.0/disk.raw"
  file_name = "kamerplanter-appliance-0.1.0.raw"
  checksum  = "<sha256>"
}

module "appliance" {
  source = "github.com/nolte/kamerplanter-infrastructure//src/modules/proxmox-appliance-vm?ref=v0.1.0"

  node_name       = "pve"
  image_file_id   = module.image.file_id
  ssh_public_keys = [file("~/.ssh/id_ed25519.pub")]
}

output "kamerplanter_url" {
  value = module.appliance.web_ui_url
}
```

The double slash in `source` separates the repository from the module path. Run `terraform init` after adding or changing a `source`.

Put the appliance version into `file_name`. Each release then gets its own file on the datastore, and a new release never overwrites the image of the old one.

## Run several appliances from one image

One image file can serve several VMs, for example a test and a production instance. Create the VMs with `for_each`:

```hcl
locals {
  appliances = {
    kamerplanter      = "192.168.1.50/24"
    kamerplanter-test = "192.168.1.51/24"
  }
}

module "appliance" {
  source   = "github.com/nolte/kamerplanter-infrastructure//src/modules/proxmox-appliance-vm?ref=v0.1.0"
  for_each = local.appliances

  node_name       = "pve"
  name            = each.key
  image_file_id   = module.image.file_id
  ipv4_address    = each.value
  ipv4_gateway    = "192.168.1.1"
  ssh_public_keys = [file("~/.ssh/id_ed25519.pub")]
}
```

## Keep the image and the VM on different nodes

The image module stores the file on the node that downloads it, and the VM module imports from a volume ID such as `local:import/kamerplanter-appliance-0.1.0.raw`. Use a shared datastore with the **Import** content type if the VM runs on another node than the one that downloaded the image; a node-local datastore such as `local` is only visible on its own node.

## Related

- [Reference: `proxmox-appliance-image`](../references/proxmox-appliance-image.md)
- [Reference: `proxmox-appliance-vm`](../references/proxmox-appliance-vm.md)
- [Update, resize, and remove](lifecycle.md)
