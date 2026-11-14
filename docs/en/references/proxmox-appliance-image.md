---
title: proxmox-appliance-image
audience: [terraform-author, self-hoster]
content_mode: reference
track: developer-docs
last_updated: 2026-11-14
---

# `proxmox-appliance-image`

Source: `src/modules/proxmox-appliance-image`

Downloads the raw disk image of an appliance release onto a Proxmox VE datastore with the content type `import`, and verifies its SHA-256 checksum. Resource: `proxmox_download_file`.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `node_name` | `string` | required | Node that downloads and stores the image. |
| `image_url` | `string` | required | Download URL of the raw image, normally a release asset of `nolte/kamerplanter-appliance`. Must start with `https://`. |
| `file_name` | `string` | required | File name on the datastore. Must end in `.raw`, `.qcow2`, or `.vmdk`. Include the appliance version so that releases don't overwrite each other. |
| `datastore_id` | `string` | `"local"` | Datastore for the image; must allow the `import` content type. |
| `checksum` | `string` | `null` | Expected SHA-256 checksum, lowercase hex (64 characters). Proxmox VE rejects the download on a mismatch. `null` skips the check. |
| `download_timeout` | `number` | `1800` | Seconds Proxmox VE may take for the download. |

## Outputs

| Name | Description |
|---|---|
| `file_id` | Volume ID of the image, for example `local:import/kamerplanter-appliance-0.1.0.raw`. Input `image_file_id` of `proxmox-appliance-vm`. |

## Behaviour

- Changing `file_name` replaces the file: the new one is downloaded, the old one deleted.
- With a `checksum`, an existing file is not checked against the URL again (`overwrite = false`): it stays in place even when the release asset is no longer available. Without a checksum, the provider compares the file size with the URL on every refresh and downloads again on a difference.
- `terraform destroy` deletes the file from the datastore.

## Required rights

`Datastore.AllocateTemplate` on the datastore and `Sys.AccessNetwork` on the node (alternatively `Sys.Audit` and `Sys.Modify` on `/`).

## Example

```hcl
module "image" {
  source = "github.com/nolte/kamerplanter-infrastructure//src/modules/proxmox-appliance-image?ref=v0.1.0"

  node_name = "pve"
  image_url = "https://github.com/nolte/kamerplanter-appliance/releases/download/v0.1.0/disk.raw"
  file_name = "kamerplanter-appliance-0.1.0.raw"
  checksum  = "<sha256>"
}
```
