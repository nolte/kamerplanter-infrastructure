---
title: proxmox-appliance-image
audience: [terraform-author, self-hoster]
content_mode: reference
track: developer-docs
last_updated: 2026-11-14
---

# `proxmox-appliance-image`

Quelle: `src/modules/proxmox-appliance-image`

Lädt das Raw-Disk-Image eines Appliance-Releases in einen Proxmox-VE-Datastore mit dem Inhaltstyp `import` und prüft seine SHA-256-Prüfsumme. Ressource: `proxmox_download_file`.

## Eingaben

| Name | Typ | Standard | Beschreibung |
|---|---|---|---|
| `node_name` | `string` | Pflicht | Node, der das Image herunterlädt und speichert. |
| `image_url` | `string` | Pflicht | Download-URL des Raw-Images, normalerweise ein Release-Asset von `nolte/kamerplanter-appliance`. Muss mit `https://` beginnen. |
| `file_name` | `string` | Pflicht | Dateiname im Datastore. Muss auf `.raw`, `.qcow2` oder `.vmdk` enden. Enthält die Appliance-Version, damit sich Releases nicht überschreiben. |
| `datastore_id` | `string` | `"local"` | Datastore für das Image; muss den Inhaltstyp `import` erlauben. |
| `checksum` | `string` | `null` | Erwartete SHA-256-Prüfsumme, Hex in Kleinbuchstaben (64 Zeichen). Proxmox VE weist den Download bei Abweichung ab. `null` überspringt die Prüfung. |
| `download_timeout` | `number` | `1800` | Sekunden, die Proxmox VE für den Download brauchen darf. |

## Ausgaben

| Name | Beschreibung |
|---|---|
| `file_id` | Volume-ID des Images, zum Beispiel `local:import/kamerplanter-appliance-0.1.0.raw`. Eingabe `image_file_id` von `proxmox-appliance-vm`. |

## Verhalten

- Eine Änderung von `file_name` ersetzt die Datei: Die neue wird heruntergeladen, die alte gelöscht.
- Eine vorhandene Datei wird nicht erneut gegen die URL geprüft (`overwrite = false`): Sie bleibt erhalten, auch wenn das Release-Asset nicht mehr verfügbar ist.
- `terraform destroy` löscht die Datei aus dem Datastore.

## Benötigte Rechte

`Datastore.AllocateTemplate` auf dem Datastore und `Sys.AccessNetwork` auf dem Node (alternativ `Sys.Audit` und `Sys.Modify` auf `/`).

## Beispiel

```hcl
module "image" {
  source = "github.com/nolte/kamerplanter-infrastructure//src/modules/proxmox-appliance-image?ref=v0.1.0"

  node_name = "pve"
  image_url = "https://github.com/nolte/kamerplanter-appliance/releases/download/v0.1.0/disk.raw"
  file_name = "kamerplanter-appliance-0.1.0.raw"
  checksum  = "<sha256>"
}
```
