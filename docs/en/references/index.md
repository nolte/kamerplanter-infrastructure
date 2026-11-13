---
title: References
audience: [self-hoster, terraform-author]
content_mode: meta
track: developer-docs
last_updated: 2026-11-13
---

# References

Inputs, outputs, and requirements of every module and example configuration.

| Page | Describes |
|---|---|
| [`proxmox-appliance-image`](proxmox-appliance-image.md) | Module that downloads the appliance image onto a Proxmox VE datastore |
| [`proxmox-appliance-vm`](proxmox-appliance-vm.md) | Module that creates the appliance VM from that image |
| [Example `src/scripts/proxmox`](proxmox-example.md) | Ready-to-use configuration that wires both modules |

## Requirements

| Component | Version |
|---|---|
| Terraform | 1.9 or later (CI tests with the version in `.tool-versions`) |
| OpenTofu | expected to work, not tested |
| Provider [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest/docs) | 0.122.0 or later |
| Proxmox VE | 8.4 or later |

## Environment variables

The `bpg/proxmox` provider reads its connection from the environment. The example configuration sets nothing else in its `provider` block.

| Variable | Meaning |
|---|---|
| `PROXMOX_VE_ENDPOINT` | URL of the Proxmox VE API, for example `https://pve.example.lan:8006/` |
| `PROXMOX_VE_API_TOKEN` | API token as `<user>@<realm>!<token-id>=<secret>` |
| `PROXMOX_VE_INSECURE` | `true` to accept a self-signed certificate |
