---
title: Netzwerk einrichten
audience: [self-hoster, terraform-author]
content_mode: how-to
track: user-docs
last_updated: 2026-11-13
---

# Netzwerk einrichten

Standardmäßig bekommt die Appliance ihre Adresse per DHCP an der Bridge `vmbr0`. Diese Seite zeigt, wie du das änderst. Die Einstellungen erreichen die Appliance über ihr Cloud-Init-Laufwerk.

## Feste Adresse verwenden

Mit einer festen Adresse kennt Terraform die URL der Web-UI, und sie bleibt stabil. Setze die Adresse in CIDR-Notation zusammen mit dem Gateway in `terraform.tfvars`:

```hcl
ipv4_address = "192.168.1.50/24"
ipv4_gateway = "192.168.1.1"
```

Bei einer festen Adresse ist `ipv4_gateway` Pflicht; fehlt es, bricht `terraform plan` mit einem Fehler ab. Nach `terraform apply` zeigt die Ausgabe `web_ui_url` den Wert `http://192.168.1.50:8080`.

## Appliance an eine andere Bridge oder ein VLAN hängen

Wähle die Bridge in `terraform.tfvars`:

```hcl
network_bridge = "vmbr1"
```

Die Beispielkonfiguration hat keine VLAN-Einstellung. Um den Verkehr der VM zu taggen, nutze das VM-Modul aus deiner eigenen Konfiguration und setze `vlan_id`:

```hcl
module "appliance" {
  source = "github.com/nolte/kamerplanter-infrastructure//src/modules/proxmox-appliance-vm?ref=v0.1.0"

  node_name      = "pve"
  image_file_id  = module.image.file_id
  network_bridge = "vmbr0"
  vlan_id        = 30
}
```

Die Bridge muss VLAN-fähig sein (**System → Netzwerk → vmbr0 → VLAN aware** auf dem Node).

## DNS-Server setzen

Ohne DNS-Server nutzt die Appliance die per DHCP erhaltenen. Bei einer festen Adresse setzt du sie ausdrücklich über das VM-Modul:

```hcl
module "appliance" {
  # ...
  ipv4_address = "192.168.1.50/24"
  ipv4_gateway = "192.168.1.1"
  dns_servers  = ["192.168.1.1", "9.9.9.9"]
}
```

## DHCP-Adresse an Terraform melden lassen

Bei DHCP erfährt Terraform die Adresse nur über den QEMU Guest Agent. Setze `agent_enabled = true` im VM-Modul **nur, wenn das Appliance-Image den Agent mitbringt**: sonst wartet `terraform apply` auf den Agent, bis es abbricht. Bis dahin siehst du die Adresse in deinem DHCP-Server nach oder verwendest eine feste Adresse.

## Siehe auch

- [Referenz: `proxmox-appliance-vm`](../references/proxmox-appliance-vm.md)
- [Module in der eigenen Konfiguration nutzen](own-configuration.md)
