---
title: Auf Proxmox VE bereitstellen
audience: [self-hoster]
content_mode: tutorial
track: user-docs
last_updated: 2026-11-13
---

# Auf Proxmox VE bereitstellen

Du hast einen Proxmox-VE-Node und willst Kamerplanter darauf betreiben. In diesem Tutorial bereitest du den Node einmalig vor, füllst eine kurze Einstellungsdatei aus und lässt Terraform das Appliance-Image herunterladen und die VM anlegen. Am Ende öffnest du die Kamerplanter-Web-UI im Browser.

## Was du brauchst

- Proxmox VE **8.4 oder neuer** und Shell-Zugang zum Node als `root` (für die einmalige Vorbereitung)
- [Terraform](https://developer.hashicorp.com/terraform/install) 1.9 oder neuer oder [OpenTofu](https://opentofu.org/docs/intro/install/) auf deinem Arbeitsrechner
- Einen Klon dieses Repositorys
- Ein SSH-Schlüsselpaar; der öffentliche Schlüssel kommt in die Appliance
- Download-URL und SHA-256-Prüfsumme eines Appliance-Releases von der [Release-Seite](https://github.com/nolte/kamerplanter-appliance/releases)

## Schritt 1: Disk-Images in einem Datastore erlauben

Das Image liegt in einem verzeichnisbasierten Datastore mit dem Inhaltstyp **Import**. Sieh dir auf dem Node die aktuellen Inhaltstypen von `local` an:

```bash
grep -A4 '^dir: local$' /etc/pve/storage.cfg
```

Ergänze `import` in der Liste unter `content` und behalte die vorhandenen Einträge. Für den Standard-Storage `local` ist das typischerweise:

```bash
pvesm set local --content iso,vztmpl,backup,import
```

In der Weboberfläche liegt dieselbe Einstellung unter **Rechenzentrum → Storage → local → Bearbeiten → Inhalt**.

## Schritt 2: API-Benutzer und Token anlegen

Terraform spricht über ein API-Token mit Proxmox VE. Lege einen Benutzer an, gib ihm die Rechte, VMs anzulegen und Dateien herunterzuladen, und erzeuge ein Token für ihn:

```bash
# Rolle, die Dateien aus dem Internet auf den Node laden darf
pveum role add KamerplanterDownload --privs "Sys.AccessNetwork"

pveum user add terraform@pve --comment "Terraform: Kamerplanter"
pveum acl modify / --users terraform@pve --roles PVEVMAdmin,PVEDatastoreAdmin,PVESDNUser
pveum acl modify /nodes/pve --users terraform@pve --roles KamerplanterDownload

pveum user token add terraform@pve kamerplanter --privsep 0
```

Ersetze `pve` in `/nodes/pve` durch den Namen deines Nodes. Der letzte Befehl zeigt das Token-Secret nur einmal an; kopiere es jetzt. Die Token-ID ist `terraform@pve!kamerplanter`.

!!! note "Hinweis"
    `--privsep 0` lässt das Token die Rechte seines Benutzers nutzen. Ohne diese Option vergibst du dieselben Rollen dem Token selbst (`--tokens 'terraform@pve!kamerplanter'`).

## Schritt 3: Terraform sagen, wo dein Node ist

Exportiere auf deinem Arbeitsrechner die Verbindungsdaten. Terraform liest sie aus der Umgebung, sie landen also in keiner Datei:

```bash
export PROXMOX_VE_ENDPOINT="https://pve.example.lan:8006/"
export PROXMOX_VE_API_TOKEN='terraform@pve!kamerplanter=<Token-Secret>'
export PROXMOX_VE_INSECURE=true   # nur wenn der Node sein selbstsigniertes Zertifikat nutzt
```

Setze das Token in einfache Anführungszeichen, sonst interpretiert deine Shell das `!`.

## Schritt 4: Einstellungen ausfüllen

Wechsle in die Beispielkonfiguration und kopiere die Vorlage:

```bash
cd src/scripts/proxmox
cp terraform.tfvars.example terraform.tfvars
```

Die Vorlage sieht so aus:

```hcl
{% include "../../../src/scripts/proxmox/terraform.tfvars.example" %}
```

Setze mindestens:

- `node_name`: den Namen deines Nodes, wie ihn die Weboberfläche zeigt
- `appliance_version`, `image_url`, `image_checksum`: das Release, das du bereitstellst, die URL seines Disk-Images und den SHA-256-Wert aus der Prüfsummendatei des Releases
- `ssh_public_keys`: den Inhalt deiner Public-Key-Datei, zum Beispiel `~/.ssh/id_ed25519.pub`

Alles andere hat einen Standardwert: 2 Kerne, 4 GiB Arbeitsspeicher, eine 32-GiB-Disk auf `local-lvm`, die Bridge `vmbr0` und eine Adresse per DHCP. Alle Einstellungen stehen in der [Referenz der Beispielkonfiguration](../references/proxmox-example.md).

`terraform.tfvars` ist von Git ausgenommen, deine Werte bleiben also lokal.

## Schritt 5: Appliance anlegen

```bash
terraform init
terraform apply
```

Terraform zeigt, was es anlegen wird: eine Image-Datei und eine VM. Bestätige mit `yes`. Der Download dauert je nach Verbindung einige Minuten; Proxmox VE prüft die Prüfsumme und weist ein beschädigtes Image ab.

Danach gibt Terraform die Ausgaben aus:

```text
ipv4_address = "192.168.1.50"
vm_id        = 100
web_ui_url   = "http://192.168.1.50:8080"
```

Bei DHCP zeigt `ipv4_address` den Wert `unknown` und `web_ui_url` bleibt leer, weil Proxmox VE die Adresse nur über den Guest Agent erfährt. Sieh die Adresse in deinem DHCP-Server oder in der VM-Konsole nach oder [gib der Appliance eine feste Adresse](../guides/network.md#feste-adresse-verwenden).

## Schritt 6: Kamerplanter öffnen

Die Appliance braucht für den ersten Start einige Minuten. Öffne dann die `web_ui_url` im Browser, zum Beispiel `http://192.168.1.50:8080`, und fahre mit der Einrichtung von Kamerplanter fort.

## Nächste Schritte

- [Netzwerk einrichten](../guides/network.md): feste Adresse, VLAN, DNS-Server
- [Aktualisieren, vergrößern, entfernen](../guides/lifecycle.md): was passiert, wenn ein neues Appliance-Release erscheint
- [Fehlerbehebung](../guides/troubleshooting.md): wenn `terraform apply` fehlschlägt
