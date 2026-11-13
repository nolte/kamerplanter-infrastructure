---
title: Fehlerbehebung
audience: [self-hoster, terraform-author]
content_mode: troubleshooting
track: user-docs
last_updated: 2026-11-13
---

# Fehlerbehebung

`terraform apply` ist fehlgeschlagen oder die Appliance ist nicht erreichbar. Such dein Symptom unten.

## Der Download scheitert mit „Permission check failed“ oder HTTP 403

**Symptom:** Das Anlegen von `module.image.proxmox_download_file.this` scheitert mit einem Rechtefehler.

**Ursache:** Eine Datei aus dem Internet auf den Node zu laden braucht `Datastore.AllocateTemplate` auf dem Datastore und `Sys.AccessNetwork` auf dem Node. Die Rollen `PVEVMAdmin` und `PVEDatastoreAdmin` allein enthalten `Sys.AccessNetwork` nicht.

**Lösung:** Vergib die Download-Rolle auf dem Node, wie in [Schritt 2 des Tutorials](../getting-started/proxmox.md#schritt-2-api-benutzer-und-token-anlegen):

```bash
pveum role add KamerplanterDownload --privs "Sys.AccessNetwork"
pveum acl modify /nodes/<node> --users terraform@pve --roles KamerplanterDownload
```

## Der Datastore unterstützt den Inhaltstyp „import“ nicht

**Symptom:** Der Download scheitert, weil der Datastore den Inhaltstyp `import` nicht erlaubt.

**Ursache:** Beim Image-Datastore (Standard `local`) ist **Import** nicht aktiviert, oder es ist ein Block-Storage wie LVM-thin, der keine Dateien aufnehmen kann.

**Lösung:** Aktiviere **Import** auf einem verzeichnisbasierten Datastore wie in [Schritt 1 des Tutorials](../getting-started/proxmox.md#schritt-1-disk-images-in-einem-datastore-erlauben), oder setze `image_datastore_id` auf einen Datastore, der ihn hat.

## Die Prüfsumme stimmt nicht

**Symptom:** Proxmox VE weist die heruntergeladene Datei wegen einer abweichenden Prüfsumme ab.

**Ursache:** `image_checksum` gehört zu einem anderen Release oder einer anderen Datei als `image_url`, oder der Download war beschädigt.

**Lösung:** Kopiere den SHA-256-Wert erneut aus der Prüfsummendatei genau des Releases in `image_url` und führe `terraform apply` noch einmal aus.

## `terraform apply` hängt beim Anlegen der VM

**Symptom:** Das Anlegen von `module.appliance.proxmox_virtual_environment_vm.this` läuft viele Minuten und bricht dann wegen Zeitüberschreitung ab.

**Ursache:** `agent_enabled = true`, obwohl das Appliance-Image keinen QEMU Guest Agent hat. Terraform wartet darauf, dass der Agent die Adresse meldet.

**Lösung:** Setze `agent_enabled = false` (Standard) und verwende eine [feste Adresse](network.md#feste-adresse-verwenden), wenn du die Adresse in Terraform brauchst.

## `web_ui_url` ist leer und `ipv4_address` ist „unknown“

**Symptom:** Nach einem erfolgreichen `terraform apply` zeigen die Ausgaben keine Adresse.

**Ursache:** Die Appliance hat ihre Adresse per DHCP bekommen und der Guest Agent ist aus, Proxmox VE kennt die Adresse also nicht.

**Workaround:** Sieh die Adresse in deinem DHCP-Server oder in der VM-Konsole der Proxmox-VE-Weboberfläche nach und öffne `http://<Adresse>:8080`.

**Lösung:** Gib der Appliance eine [feste Adresse](network.md#feste-adresse-verwenden).

## Die Web-UI antwortet nicht

**Symptom:** `http://<Adresse>:8080` lädt nicht.

**Ursache:** Der erste Start ist noch nicht fertig, oder die VM hängt in einem Netz, das dein Browser nicht erreicht.

**Workaround:** Warte nach dem ersten Start einige Minuten und lade neu. Prüfe in der Proxmox-VE-Konsole, ob die VM läuft und die erwartete Adresse hat und ob dein Arbeitsrechner dieses Netz erreicht.

## Terraform meldet „Invalid value for variable“

**Symptom:** `terraform plan` bricht mit einem Validierungsfehler für eine der Eingaben ab.

**Ursache:** Die Module prüfen Eingaben, bevor etwas angelegt wird, zum Beispiel ob `image_url` https verwendet, ob `ipv4_address` `dhcp` oder CIDR ist und ob eine feste Adresse ein Gateway hat.

**Lösung:** Korrigiere den in der Meldung genannten Wert. Die Regeln für jede Eingabe stehen in den [Referenzen](../references/index.md).
