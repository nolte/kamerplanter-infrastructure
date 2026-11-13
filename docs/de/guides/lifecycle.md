---
title: Aktualisieren, vergrößern, entfernen
audience: [self-hoster, terraform-author]
content_mode: how-to
track: user-docs
last_updated: 2026-11-13
---

# Aktualisieren, vergrößern, entfernen

Deine Appliance läuft und du willst sie ändern. Die Disk der Appliance enthält das Betriebssystem **und alle Kamerplanter-Daten**, deshalb sind die Module darauf ausgelegt, diese Disk zu behalten. Diese Seite zeigt, welche Änderungen sicher sind und welche Daten löschen.

## Auf ein neues Appliance-Release aktualisieren

Für Updates brauchst du Terraform nicht: Die Appliance aktualisiert sich selbst, wie in der [Appliance-Dokumentation](https://github.com/nolte/kamerplanter-appliance) beschrieben.

Du kannst die Beispielkonfiguration trotzdem auf ein neues Release umstellen, damit später angelegte VMs mit einem aktuellen Image starten. Ändere die drei Release-Werte in `terraform.tfvars`:

```hcl
appliance_version = "0.2.0"
image_url         = "https://github.com/nolte/kamerplanter-appliance/releases/download/v0.2.0/disk.raw"
image_checksum    = "<sha256 von 0.2.0>"
```

`terraform apply` lädt dann das neue Image herunter und löscht die alte Image-Datei. Die laufende VM bleibt **unberührt**: Das Modul ignoriert ein geändertes Image bei bestehenden VMs.

## Der Appliance mehr Ressourcen geben

Ändere `cores`, `memory` oder `disk_size` in `terraform.tfvars` und führe `terraform apply` aus. Terraform ändert die VM direkt; der Provider startet die VM unter Umständen neu, um neue CPU- oder Speichereinstellungen anzuwenden.

```hcl
cores     = 4
memory    = 8192   # MiB
disk_size = 64     # GiB
```

Die Disk kann nur wachsen. Ein kleinerer `disk_size` als der aktuelle schlägt fehl.

## Mit einer frischen VM neu anfangen

!!! danger "Das löscht alle Kamerplanter-Daten auf der VM"
    Lege vorher in Kamerplanter ein Backup an.

So ersetzt du die VM durch eine, die aus dem aktuellen Image angelegt wird:

```bash
terraform apply -replace='module.appliance.proxmox_virtual_environment_vm.this'
```

## Appliance entfernen

!!! danger "Das löscht die VM, ihre Disk mit allen Daten und die Image-Datei"
    Lege vorher in Kamerplanter ein Backup an.

```bash
terraform destroy
```

API-Benutzer, Token, Rolle und der Inhaltstyp **Import** am Datastore bleiben bestehen. Entferne sie auf dem Node, wenn du sie nicht mehr brauchst:

```bash
pveum user delete terraform@pve
pveum role delete KamerplanterDownload
```

## Siehe auch

- [Referenz: `proxmox-appliance-vm`](../references/proxmox-appliance-vm.md)
- [Fehlerbehebung](troubleshooting.md)
