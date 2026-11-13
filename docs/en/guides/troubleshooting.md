---
title: Troubleshooting
audience: [self-hoster, terraform-author]
content_mode: troubleshooting
track: user-docs
last_updated: 2026-11-13
---

# Troubleshooting

`terraform apply` failed or the appliance is not reachable. Find your symptom below.

## The download fails with "Permission check failed" or HTTP 403

**Symptom:** creating `module.image.proxmox_download_file.this` fails with a permission error.

**Cause:** downloading a file from the internet onto the node needs `Datastore.AllocateTemplate` on the datastore and `Sys.AccessNetwork` on the node. The roles `PVEVMAdmin` and `PVEDatastoreAdmin` alone don't include `Sys.AccessNetwork`.

**Resolution:** grant the download role on the node, as in [step 2 of the tutorial](../getting-started/proxmox.md#step-2-create-an-api-user-and-token):

```bash
pveum role add KamerplanterDownload --privs "Sys.AccessNetwork"
pveum acl modify /nodes/<node> --users terraform@pve --roles KamerplanterDownload
```

## The datastore doesn't support the content type "import"

**Symptom:** the download fails because the datastore doesn't allow the `import` content type.

**Cause:** the image datastore (default `local`) doesn't have **Import** enabled, or it is a block storage such as LVM-thin, which can't hold files.

**Resolution:** enable **Import** on a directory-based datastore as in [step 1 of the tutorial](../getting-started/proxmox.md#step-1-allow-disk-images-on-a-datastore), or point `image_datastore_id` at one that has it.

## The checksum doesn't match

**Symptom:** Proxmox VE rejects the downloaded file because of a checksum mismatch.

**Cause:** `image_checksum` belongs to another release or file than `image_url`, or the download was damaged.

**Resolution:** copy the SHA-256 value again from the checksum file of exactly the release in `image_url`, then rerun `terraform apply`.

## `terraform apply` hangs while creating the VM

**Symptom:** creating `module.appliance.proxmox_virtual_environment_vm.this` keeps running for many minutes and then times out.

**Cause:** `agent_enabled = true` while the appliance image has no QEMU guest agent. Terraform waits for the agent to report the address.

**Resolution:** set `agent_enabled = false` (the default) and use a [static address](network.md#use-a-static-address) if you need the address in Terraform.

## `web_ui_url` is empty and `ipv4_address` is "unknown"

**Symptom:** the outputs show no address after a successful `terraform apply`.

**Cause:** the appliance got its address from DHCP and the guest agent is disabled, so Proxmox VE doesn't know the address.

**Workaround:** look up the address in your DHCP server or in the VM console in the Proxmox VE web interface, then open `http://<address>:8080`.

**Resolution:** give the appliance a [static address](network.md#use-a-static-address).

## The web UI doesn't answer

**Symptom:** `http://<address>:8080` doesn't load.

**Cause:** the first start isn't finished yet, or the VM is on a network your browser can't reach.

**Workaround:** wait a few minutes after the first start and reload. Check in the Proxmox VE console that the VM is running and has the expected address, and that your workstation can reach that network.

## Terraform reports "Invalid value for variable"

**Symptom:** `terraform plan` stops with a validation error for one of the inputs.

**Cause:** the modules check inputs before anything is created, for example that `image_url` uses https, that `ipv4_address` is `dhcp` or CIDR, and that a static address has a gateway.

**Resolution:** correct the value named in the message. The rules for every input are listed in the [references](../references/index.md).
