---
title: Deploy on Proxmox VE
audience: [self-hoster]
content_mode: tutorial
track: user-docs
last_updated: 2026-11-13
---

# Deploy on Proxmox VE

You have a Proxmox VE node and want Kamerplanter running on it. In this tutorial you prepare the node once, fill in a short settings file, and let Terraform download the appliance image and create the VM. At the end you open the Kamerplanter web UI in your browser.

## What you need

- Proxmox VE **8.4 or later** and shell access to the node as `root` (for the one-time preparation)
- [Terraform](https://developer.hashicorp.com/terraform/install) 1.9 or later, or [OpenTofu](https://opentofu.org/docs/intro/install/), on your workstation
- A clone of this repository
- An SSH key pair; the public key goes into the appliance
- The download URL and SHA-256 checksum of an appliance release from the [release page](https://github.com/nolte/kamerplanter-appliance/releases)

## Step 1: Allow disk images on a datastore

The image is stored on a directory-based datastore with the content type **Import**. On the node, look at the current content types of `local`:

```bash
grep -A4 '^dir: local$' /etc/pve/storage.cfg
```

Add `import` to the list shown under `content`, keeping the existing entries. For the default `local` storage this is typically:

```bash
pvesm set local --content iso,vztmpl,backup,import
```

In the web interface the same setting is under **Datacenter → Storage → local → Edit → Content**.

## Step 2: Create an API user and token

Terraform talks to Proxmox VE through an API token. Create a user, give it the rights to create VMs and to download files, and create a token for it:

```bash
# Role that may download files from the internet onto the node
pveum role add KamerplanterDownload --privs "Sys.AccessNetwork"

pveum user add terraform@pve --comment "Terraform: Kamerplanter"
pveum acl modify / --users terraform@pve --roles PVEVMAdmin,PVEDatastoreAdmin,PVESDNUser
pveum acl modify /nodes/pve --users terraform@pve --roles KamerplanterDownload

pveum user token add terraform@pve kamerplanter --privsep 0
```

Replace `pve` in `/nodes/pve` with the name of your node. The last command prints the token secret once; copy it now. The token ID is `terraform@pve!kamerplanter`.

!!! note
    `--privsep 0` lets the token use the rights of its user. Without it, grant the same roles to the token itself (`--tokens 'terraform@pve!kamerplanter'`).

## Step 3: Tell Terraform where your node is

On your workstation, export the connection settings. Terraform reads them from the environment, so they never end up in a file:

```bash
export PROXMOX_VE_ENDPOINT="https://pve.example.lan:8006/"
export PROXMOX_VE_API_TOKEN='terraform@pve!kamerplanter=<token secret>'
export PROXMOX_VE_INSECURE=true   # only if the node uses its self-signed certificate
```

Use single quotes around the token: the `!` would otherwise be interpreted by your shell.

## Step 4: Fill in the settings

Change into the example configuration and copy the settings template:

```bash
cd src/scripts/proxmox
cp terraform.tfvars.example terraform.tfvars
```

The template looks like this:

```hcl
{% include "../../../src/scripts/proxmox/terraform.tfvars.example" %}
```

Set at least:

- `node_name`: the name of your node, as shown in the web interface
- `appliance_version`, `image_url`, `image_checksum`: the release you deploy, its disk image URL, and the SHA-256 value from the release's checksum file
- `ssh_public_keys`: the content of your public key file, for example `~/.ssh/id_ed25519.pub`

Everything else has a default: 2 cores, 4 GiB memory, a 32 GiB disk on `local-lvm`, the bridge `vmbr0`, and an address from DHCP. All settings are listed in the [reference of the example configuration](../references/proxmox-example.md).

`terraform.tfvars` is excluded from Git, so your values stay local.

## Step 5: Create the appliance

```bash
terraform init
terraform apply
```

Terraform shows what it will create: one image file and one VM. Confirm with `yes`. The download takes a few minutes, depending on your connection; Proxmox VE checks the checksum and rejects a damaged image.

When it is done, Terraform prints the outputs:

```text
ipv4_address = "192.168.1.50"
vm_id        = 100
web_ui_url   = "http://192.168.1.50:8080"
```

With DHCP, `ipv4_address` shows `unknown` and `web_ui_url` stays empty, because Proxmox VE learns the address only through the guest agent. Look up the address in your DHCP server or in the VM console, or [give the appliance a static address](../guides/network.md#use-a-static-address).

## Step 6: Open Kamerplanter

The appliance needs a few minutes for its first start. Then open the `web_ui_url` in your browser, for example `http://192.168.1.50:8080`, and continue with the Kamerplanter setup.

## Next steps

- [Configure the network](../guides/network.md): static address, VLAN, DNS servers
- [Update, resize, and remove](../guides/lifecycle.md): what happens when a new appliance release comes out
- [Troubleshooting](../guides/troubleshooting.md): if `terraform apply` fails
