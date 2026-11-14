---
title: Beispiel src/scripts/proxmox
audience: [self-hoster]
content_mode: reference
track: user-docs
last_updated: 2026-11-14
---

# Beispiel `src/scripts/proxmox`

Fertige Root-Konfiguration, die [`proxmox-appliance-image`](proxmox-appliance-image.md) und [`proxmox-appliance-vm`](proxmox-appliance-vm.md) verbindet. Das Image wird als `kamerplanter-appliance-<appliance_version>.raw` gespeichert.

## Eingaben

Gesetzt in `terraform.tfvars`.

| Name | Typ | Standard | Weitergegeben an |
|---|---|---|---|
| `node_name` | `string` | Pflicht | beide Module, `node_name` |
| `appliance_version` | `string` | Pflicht | Image-Modul, Teil von `file_name` |
| `image_url` | `string` | Pflicht | Image-Modul, `image_url` |
| `image_checksum` | `string` | `null` | Image-Modul, `checksum` |
| `reinstall_generation` | `number` | `0` | VM-Modul, `reinstall_generation`; **Erhöhen löscht alle Daten auf der VM** |
| `image_datastore_id` | `string` | `"local"` | Image-Modul, `datastore_id` |
| `vm_datastore_id` | `string` | `"local-lvm"` | VM-Modul, `datastore_id` |
| `vm_name` | `string` | `"kamerplanter"` | VM-Modul, `name` |
| `disk_size` | `number` | `32` | VM-Modul, `disk_size` (GiB) |
| `cores` | `number` | `2` | VM-Modul, `cores` |
| `memory` | `number` | `4096` | VM-Modul, `memory` (MiB) |
| `network_bridge` | `string` | `"vmbr0"` | VM-Modul, `network_bridge` |
| `ipv4_address` | `string` | `"dhcp"` | VM-Modul, `ipv4_address` |
| `ipv4_gateway` | `string` | `null` | VM-Modul, `ipv4_gateway` |
| `ssh_public_keys` | `list(string)` | `[]` | VM-Modul, `ssh_public_keys` |

Die VM-Modul-Eingaben `vm_id`, `vlan_id`, `dns_servers`, `agent_enabled`, `tags`, `description` und `start_on_boot` behalten hier ihre Standardwerte; setze sie, indem du [die Module in deiner eigenen Konfiguration nutzt](../guides/own-configuration.md).

## Ausgaben

| Name | Beschreibung |
|---|---|
| `vm_id` | ID der Appliance-VM. |
| `ipv4_address` | IPv4-Adresse der Appliance oder `"unknown"`. |
| `web_ui_url` | URL der Kamerplanter-Web-UI oder `null`. |

## Vorlage für die Einstellungen

`terraform.tfvars.example`:

```hcl
{% include "../../../src/scripts/proxmox/terraform.tfvars.example" %}
```
