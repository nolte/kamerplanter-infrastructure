---
title: proxmox-appliance-vm
audience: [terraform-author, self-hoster]
content_mode: reference
track: developer-docs
last_updated: 2026-11-14
---

# `proxmox-appliance-vm`

Quelle: `src/modules/proxmox-appliance-vm`

Legt die Appliance-VM an, importiert ihre Systemdisk aus einer Image-Datei und übergibt Hostname, SSH-Schlüssel und Netzwerkeinstellungen über ein Cloud-Init-Laufwerk im NoCloud-Format. Ressource: `proxmox_virtual_environment_vm`.

## Eingaben

| Name | Typ | Standard | Beschreibung |
|---|---|---|---|
| `node_name` | `string` | Pflicht | Node, auf dem die VM läuft. |
| `image_file_id` | `string` | Pflicht | Volume-ID des Images, die Ausgabe `file_id` von `proxmox-appliance-image`. Wird nur beim Anlegen der VM gelesen. |
| `reinstall_generation` | `number` | `0` | Um eins erhöhen, um die VM aus `image_file_id` neu zu installieren. **Jede Änderung löscht die VM und alle Daten auf ihrer Disk.** |
| `name` | `string` | `"kamerplanter"` | VM-Name, zugleich Hostname der Appliance. |
| `vm_id` | `number` | `null` | VM-ID; `null` lässt Proxmox VE die nächste freie wählen. |
| `description` | `string` | `"Kamerplanter appliance, managed by Terraform"` | Beschreibung in der Proxmox-VE-Weboberfläche. |
| `tags` | `list(string)` | `["kamerplanter"]` | Tags der VM. |
| `datastore_id` | `string` | `"local-lvm"` | Datastore für Systemdisk und Cloud-Init-Laufwerk. |
| `disk_size` | `number` | `32` | Systemdisk in GiB; enthält Betriebssystem und alle Kamerplanter-Daten. Kann nur wachsen. |
| `cores` | `number` | `2` | CPU-Kerne. |
| `memory` | `number` | `4096` | Arbeitsspeicher in MiB. |
| `network_bridge` | `string` | `"vmbr0"` | Bridge, an der die VM hängt. |
| `vlan_id` | `number` | `null` | VLAN-Tag; `null` für ungetaggt. |
| `ipv4_address` | `string` | `"dhcp"` | `"dhcp"` oder eine Adresse in CIDR-Notation, zum Beispiel `"192.168.1.50/24"`. |
| `ipv4_gateway` | `string` | `null` | Gateway; Pflicht bei fester `ipv4_address`, bei DHCP ignoriert. |
| `dns_servers` | `list(string)` | `[]` | DNS-Server; leer nutzt die von DHCP oder vom Host. |
| `ssh_public_keys` | `list(string)` | `[]` | Öffentliche SSH-Schlüssel für den administrativen Zugang. |
| `agent_enabled` | `bool` | `false` | QEMU Guest Agent aktivieren. Nur, wenn das Image den Agent mitbringt; sonst wartet `terraform apply` bis zur Zeitüberschreitung. |
| `start_on_boot` | `bool` | `true` | VM beim Start des Nodes starten. |

## Ausgaben

| Name | Beschreibung |
|---|---|
| `vm_id` | ID der VM. |
| `name` | Name und Hostname der VM. |
| `ipv4_address` | Die feste Adresse, die vom Guest Agent gemeldete Adresse oder `"unknown"` bei DHCP ohne Agent. |
| `web_ui_url` | `http://<Adresse>:8080`, oder `null`, solange die Adresse unbekannt ist. |

## Verhalten

- Ein geändertes `image_file_id` wird bei einer bestehenden VM ignoriert: Ein anderes Image, ob neuer oder älter, ersetzt nie die VM und ihre Daten.
- Ein geändertes `reinstall_generation` ersetzt die VM. Die neue VM importiert ihre Disk aus dem aktuellen `image_file_id`; die alte Disk und ihre Daten werden gelöscht.
- Die VM nutzt den Maschinentyp `q35`, SeaBIOS, einen VirtIO-SCSI-single-Controller, den CPU-Typ `x86-64-v2-AES` und eine VirtIO-Netzwerkkarte.
- Die Systemdisk hängt als `scsi0` mit IO-Thread, Discard und SSD-Emulation.
- `terraform destroy` löscht die VM und ihre Disk.

## Benötigte Rechte

VMs anlegen und Disks belegen, zum Beispiel die Rollen `PVEVMAdmin` und `PVEDatastoreAdmin` auf `/`, dazu `SDN.Use` auf der Bridge (Rolle `PVESDNUser`).

## Beispiel

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
