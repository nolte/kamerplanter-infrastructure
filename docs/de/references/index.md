---
title: Referenzen
audience: [self-hoster, terraform-author]
content_mode: meta
track: developer-docs
last_updated: 2026-11-13
---

# Referenzen

Eingaben, Ausgaben und Voraussetzungen aller Module und Beispielkonfigurationen.

| Seite | Beschreibt |
|---|---|
| [`proxmox-appliance-image`](proxmox-appliance-image.md) | Modul, das das Appliance-Image in einen Proxmox-VE-Datastore lädt |
| [`proxmox-appliance-vm`](proxmox-appliance-vm.md) | Modul, das daraus die Appliance-VM anlegt |
| [Beispiel `src/scripts/proxmox`](proxmox-example.md) | Fertige Konfiguration, die beide Module verbindet |

## Voraussetzungen

| Komponente | Version |
|---|---|
| Terraform | 1.9 oder neuer (CI testet mit der Version aus `.tool-versions`) |
| OpenTofu | sollte funktionieren, nicht getestet |
| Provider [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest/docs) | 0.122.0 oder neuer |
| Proxmox VE | 8.4 oder neuer |

## Umgebungsvariablen

Der Provider `bpg/proxmox` liest seine Verbindung aus der Umgebung. Die Beispielkonfiguration setzt in ihrem `provider`-Block nichts weiter.

| Variable | Bedeutung |
|---|---|
| `PROXMOX_VE_ENDPOINT` | URL der Proxmox-VE-API, zum Beispiel `https://pve.example.lan:8006/` |
| `PROXMOX_VE_API_TOKEN` | API-Token als `<user>@<realm>!<token-id>=<secret>` |
| `PROXMOX_VE_INSECURE` | `true`, um ein selbstsigniertes Zertifikat zu akzeptieren |
