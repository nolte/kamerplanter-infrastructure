---
title: Update, resize, and remove
audience: [self-hoster, terraform-author]
content_mode: how-to
track: user-docs
last_updated: 2026-11-14
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

The same holds the other way round: if `terraform.tfvars` still names an older release than the one the appliance has updated itself to, `terraform apply` does **not** roll the appliance back.

## Give the appliance more resources

Change `cores`, `memory`, or `disk_size` in `terraform.tfvars` and run `terraform apply`. Terraform changes the VM in place; the provider may restart the VM to apply new CPU or memory settings.

```hcl
cores     = 4
memory    = 8192   # MiB
disk_size = 64     # GiB
```

The disk can only grow. Setting a smaller `disk_size` than the current one fails.

## Reinstall a specific release

!!! danger "This deletes all Kamerplanter data on the VM"
    Create a backup in Kamerplanter first. Terraform can't change the release of a running appliance; it can only replace the VM with a new one.

To go back to an older release, or to start over from a release of your choice, set that release and raise `reinstall_generation` by one:

```hcl
appliance_version    = "0.1.0"
image_url            = "https://github.com/nolte/kamerplanter-appliance/releases/download/v0.1.0/disk.raw"
image_checksum       = "<sha256 of 0.1.0>"
reinstall_generation = 1   # was 0
```

`terraform apply` shows `must be replaced` for `module.appliance.proxmox_virtual_environment_vm.this`. Confirm only if you mean it. Afterwards, leave `reinstall_generation` at its new value: **every** change, including setting it back, reinstalls again.

`terraform apply -replace='module.appliance.proxmox_virtual_environment_vm.this'` also reinstalls once, without changing the file. It too uses the release in `appliance_version`, **not** the one the appliance is running: if the appliance has updated itself since, this is a downgrade. Replacing or tainting `module.appliance.terraform_data.reinstall` reinstalls as well.

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
