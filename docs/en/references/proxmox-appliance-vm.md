---
title: proxmox-appliance-vm
audience: [terraform-author, self-hoster]
content_mode: reference
track: developer-docs
last_updated: 2026-11-13
---

# `proxmox-appliance-vm`

Source: `src/modules/proxmox-appliance-vm`

Creates the appliance VM, imports its system disk from an image file, and passes hostname, SSH keys, and network settings through a cloud-init drive in NoCloud format. Resource: `proxmox_virtual_environment_vm`.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `node_name` | `string` | required | Node that runs the VM. |
| `image_file_id` | `string` | required | Volume ID of the image, the `file_id` output of `proxmox-appliance-image`. Read only when the VM is created. |
| `name` | `string` | `"kamerplanter"` | VM name, also the hostname of the appliance. |
| `vm_id` | `number` | `null` | VM ID; `null` lets Proxmox VE pick the next free one. |
| `description` | `string` | `"Kamerplanter appliance, managed by Terraform"` | Description in the Proxmox VE web interface. |
| `tags` | `list(string)` | `["kamerplanter"]` | Tags of the VM. |
| `datastore_id` | `string` | `"local-lvm"` | Datastore for the system disk and the cloud-init drive. |
| `disk_size` | `number` | `32` | System disk in GiB; holds the operating system and all Kamerplanter data. Can only grow. |
| `cores` | `number` | `2` | CPU cores. |
| `memory` | `number` | `4096` | Memory in MiB. |
| `network_bridge` | `string` | `"vmbr0"` | Bridge the VM is attached to. |
| `vlan_id` | `number` | `null` | VLAN tag; `null` for untagged. |
| `ipv4_address` | `string` | `"dhcp"` | `"dhcp"` or an address in CIDR notation, for example `"192.168.1.50/24"`. |
| `ipv4_gateway` | `string` | `null` | Gateway; required with a static `ipv4_address`, ignored with DHCP. |
| `dns_servers` | `list(string)` | `[]` | DNS servers; empty uses those from DHCP or the host. |
| `ssh_public_keys` | `list(string)` | `[]` | SSH public keys for administrative access. |
| `agent_enabled` | `bool` | `false` | Enable the QEMU guest agent. Only if the image ships the agent; otherwise `terraform apply` waits until it times out. |
| `start_on_boot` | `bool` | `true` | Start the VM when the node boots. |

## Outputs

| Name | Description |
|---|---|
| `vm_id` | ID of the VM. |
| `name` | Name and hostname of the VM. |
| `ipv4_address` | The static address, the address reported by the guest agent, or `"unknown"` with DHCP and no agent. |
| `web_ui_url` | `http://<address>:8080`, or `null` while the address is unknown. |

## Behaviour

- A changed `image_file_id` is ignored for an existing VM: a newer image never replaces the VM and its data.
- The VM uses the machine type `q35`, SeaBIOS, a VirtIO SCSI single controller, the CPU type `x86-64-v2-AES`, and a VirtIO network card.
- The system disk is attached as `scsi0` with IO thread, discard, and SSD emulation.
- `terraform destroy` deletes the VM and its disk.

## Required rights

Creating VMs and allocating disks, for example the roles `PVEVMAdmin` and `PVEDatastoreAdmin` on `/`, plus `SDN.Use` on the bridge (role `PVESDNUser`).

## Example

```hcl
module "appliance" {
  source = "github.com/nolte/kamerplanter-infrastructure//src/modules/proxmox-appliance-vm?ref=v0.1.0"

  node_name       = "pve"
  image_file_id   = module.image.file_id
  memory          = 8192
  ipv4_address    = "192.168.1.50/24"
  ipv4_gateway    = "192.168.1.1"
  ssh_public_keys = ["ssh-ed25519 AAAA... admin@example"]
}
```
