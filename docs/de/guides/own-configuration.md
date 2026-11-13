---
title: Module in der eigenen Konfiguration nutzen
audience: [terraform-author]
content_mode: how-to
track: developer-docs
last_updated: 2026-11-13
---

# Module in der eigenen Konfiguration nutzen

Das Beispiel in `src/scripts/proxmox` deckt den üblichen Fall ab. Wenn du deinen Proxmox-VE-Node schon mit Terraform oder OpenTofu verwaltest, rufe die beiden Module stattdessen aus deiner eigenen Konfiguration auf.

## Module einbinden

Lade die Module direkt von GitHub und pinne `ref` auf einen Release-Tag, nie auf einen Branch:

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

provider "proxmox" {}   # liest PROXMOX_VE_ENDPOINT und PROXMOX_VE_API_TOKEN

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

Der doppelte Schrägstrich in `source` trennt Repository und Modulpfad. Führe nach dem Hinzufügen oder Ändern einer `source` `terraform init` aus.

Nimm die Appliance-Version in `file_name` auf. Dann bekommt jedes Release seine eigene Datei im Datastore, und ein neues Release überschreibt nie das Image des alten.

## Mehrere Appliances aus einem Image

Eine Image-Datei kann mehrere VMs versorgen, zum Beispiel eine Test- und eine Produktivinstanz. Lege die VMs mit `for_each` an:

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

## Image und VM auf verschiedenen Nodes

Das Image-Modul speichert die Datei auf dem Node, der sie herunterlädt, und das VM-Modul importiert aus einer Volume-ID wie `local:import/kamerplanter-appliance-0.1.0.raw`. Verwende einen gemeinsamen Datastore mit dem Inhaltstyp **Import**, wenn die VM auf einem anderen Node läuft als dem, der das Image geladen hat; ein node-lokaler Datastore wie `local` ist nur auf seinem eigenen Node sichtbar.

## Siehe auch

- [Referenz: `proxmox-appliance-image`](../references/proxmox-appliance-image.md)
- [Referenz: `proxmox-appliance-vm`](../references/proxmox-appliance-vm.md)
- [Aktualisieren, vergrößern, entfernen](lifecycle.md)
