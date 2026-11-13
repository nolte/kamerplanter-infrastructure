# Kamerplanter appliance on Proxmox VE

Example root configuration that deploys the appliance as a VM on a Proxmox VE node. It uses two modules:

- [`proxmox-appliance-image`](../../modules/proxmox-appliance-image) downloads the raw disk image of an appliance release onto a datastore of the node.
- [`proxmox-appliance-vm`](../../modules/proxmox-appliance-vm) creates the VM, imports its system disk from that image, and passes hostname, SSH keys, and network settings through a cloud-init drive.

## Prerequisites

- Proxmox VE 8.4 or later (import of disk images through the API)
- A directory-based datastore with the content type **Import** enabled, e.g. `local` (Datacenter → Storage → Edit → Content)
- An API token with the rights to download files, create VMs, and allocate disks, e.g. on `/` with the roles `PVEVMAdmin` and `PVEDatastoreAdmin`

## Usage

```bash
export PROXMOX_VE_ENDPOINT="https://pve.example.lan:8006/"
export PROXMOX_VE_API_TOKEN='terraform@pve!kamerplanter=<secret>'
export PROXMOX_VE_INSECURE=true   # only for a self-signed certificate

cp terraform.tfvars.example terraform.tfvars   # set node, release, checksum, SSH key
terraform init
terraform apply
```

`web_ui_url` shows the address of the web UI when it is known: always with a static address, with DHCP only if the guest agent is enabled in the VM module. Otherwise look up the address in the DHCP server or the VM console.

## Updates

The appliance updates itself. Changing `appliance_version` downloads the new image, but existing VMs keep their disk; the new image is used only for VMs created afterwards.
