---
title: Configure the network
audience: [self-hoster, terraform-author]
content_mode: how-to
track: user-docs
last_updated: 2026-11-13
---

# Configure the network

By default the appliance gets its address from DHCP on the bridge `vmbr0`. This page shows how to change that. The settings are passed to the appliance through its cloud-init drive.

## Use a static address

A static address makes the web UI URL known to Terraform and keeps it stable. Set the address in CIDR notation together with the gateway in `terraform.tfvars`:

```hcl
ipv4_address = "192.168.1.50/24"
ipv4_gateway = "192.168.1.1"
```

`ipv4_gateway` is required with a static address; `terraform plan` stops with an error if it is missing. After `terraform apply`, the output `web_ui_url` shows `http://192.168.1.50:8080`.

## Attach the appliance to another bridge or VLAN

Choose the bridge in `terraform.tfvars`:

```hcl
network_bridge = "vmbr1"
```

The example configuration has no VLAN setting. To tag the VM's traffic, use the VM module from your own configuration and set `vlan_id`:

```hcl
module "appliance" {
  source = "github.com/nolte/kamerplanter-infrastructure//src/modules/proxmox-appliance-vm?ref=v0.1.0"

  node_name      = "pve"
  image_file_id  = module.image.file_id
  network_bridge = "vmbr0"
  vlan_id        = 30
}
```

The bridge must be VLAN-aware (**System → Network → vmbr0 → VLAN aware** on the node).

## Set DNS servers

Without DNS servers, the appliance uses those it receives from DHCP. With a static address, set them explicitly through the VM module:

```hcl
module "appliance" {
  # ...
  ipv4_address = "192.168.1.50/24"
  ipv4_gateway = "192.168.1.1"
  dns_servers  = ["192.168.1.1", "9.9.9.9"]
}
```

## Let Terraform report a DHCP address

With DHCP, Terraform learns the address only from the QEMU guest agent. Set `agent_enabled = true` in the VM module **only if the appliance image ships the agent**: otherwise `terraform apply` waits for the agent until it times out. Until then, look up the address in your DHCP server or use a static address.

## Related

- [Reference: `proxmox-appliance-vm`](../references/proxmox-appliance-vm.md)
- [Use the modules in your configuration](own-configuration.md)
