---
title: Update, resize, and remove
audience: [self-hoster, terraform-author]
content_mode: how-to
track: user-docs
last_updated: 2026-11-13
---

# Update, resize, and remove

Your appliance is running and you want to change it. The appliance disk holds the operating system **and all Kamerplanter data**, so the modules are built to keep that disk. This page shows which changes are safe and which delete data.

## Update to a new appliance release

You don't need Terraform for updates: the appliance updates itself, as described in the [appliance documentation](https://github.com/nolte/kamerplanter-appliance).

You can still move the example configuration to a new release, so that VMs you create later start from a current image. Change the three release values in `terraform.tfvars`:

```hcl
appliance_version = "0.2.0"
image_url         = "https://github.com/nolte/kamerplanter-appliance/releases/download/v0.2.0/disk.raw"
image_checksum    = "<sha256 of 0.2.0>"
```

`terraform apply` then downloads the new image and deletes the old image file. The running VM is **not** touched: the module ignores a changed image for existing VMs.

## Give the appliance more resources

Change `cores`, `memory`, or `disk_size` in `terraform.tfvars` and run `terraform apply`. Terraform changes the VM in place; the provider may restart the VM to apply new CPU or memory settings.

```hcl
cores     = 4
memory    = 8192   # MiB
disk_size = 64     # GiB
```

The disk can only grow. Setting a smaller `disk_size` than the current one fails.

## Start over with a fresh VM

!!! danger "This deletes all Kamerplanter data on the VM"
    Create a backup in Kamerplanter first.

To replace the VM with one created from the current image:

```bash
terraform apply -replace='module.appliance.proxmox_virtual_environment_vm.this'
```

## Remove the appliance

!!! danger "This deletes the VM, its disk with all data, and the image file"
    Create a backup in Kamerplanter first.

```bash
terraform destroy
```

The API user, token, role, and the **Import** content type on the datastore stay in place. Remove them on the node if you don't need them anymore:

```bash
pveum user delete terraform@pve
pveum role delete KamerplanterDownload
```

## Related

- [Reference: `proxmox-appliance-vm`](../references/proxmox-appliance-vm.md)
- [Troubleshooting](troubleshooting.md)
