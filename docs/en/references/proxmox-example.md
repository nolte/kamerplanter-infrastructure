---
title: Example src/scripts/proxmox
audience: [self-hoster]
content_mode: reference
track: user-docs
last_updated: 2026-11-13
---

# Example `src/scripts/proxmox`

Ready-to-use root configuration that wires [`proxmox-appliance-image`](proxmox-appliance-image.md) and [`proxmox-appliance-vm`](proxmox-appliance-vm.md). The image is stored as `kamerplanter-appliance-<appliance_version>.raw`.

## Inputs

Set in `terraform.tfvars`.

| Name | Type | Default | Passed to |
|---|---|---|---|
| `node_name` | `string` | required | both modules, `node_name` |
| `appliance_version` | `string` | required | image module, part of `file_name` |
| `image_url` | `string` | required | image module, `image_url` |
| `image_checksum` | `string` | `null` | image module, `checksum` |
| `image_datastore_id` | `string` | `"local"` | image module, `datastore_id` |
| `vm_datastore_id` | `string` | `"local-lvm"` | VM module, `datastore_id` |
| `vm_name` | `string` | `"kamerplanter"` | VM module, `name` |
| `disk_size` | `number` | `32` | VM module, `disk_size` (GiB) |
| `cores` | `number` | `2` | VM module, `cores` |
| `memory` | `number` | `4096` | VM module, `memory` (MiB) |
| `network_bridge` | `string` | `"vmbr0"` | VM module, `network_bridge` |
| `ipv4_address` | `string` | `"dhcp"` | VM module, `ipv4_address` |
| `ipv4_gateway` | `string` | `null` | VM module, `ipv4_gateway` |
| `ssh_public_keys` | `list(string)` | `[]` | VM module, `ssh_public_keys` |

The VM module inputs `vm_id`, `vlan_id`, `dns_servers`, `agent_enabled`, `tags`, `description`, and `start_on_boot` keep their defaults here; set them by [using the modules in your own configuration](../guides/own-configuration.md).

## Outputs

| Name | Description |
|---|---|
| `vm_id` | ID of the appliance VM. |
| `ipv4_address` | IPv4 address of the appliance, or `"unknown"`. |
| `web_ui_url` | URL of the Kamerplanter web UI, or `null`. |

## Settings template

`terraform.tfvars.example`:

```hcl
{% include "../../../src/scripts/proxmox/terraform.tfvars.example" %}
```
