# Kamerplanter Infrastructure

[![ci](https://github.com/nolte/kamerplanter-infrastructure/actions/workflows/ci.yml/badge.svg)](https://github.com/nolte/kamerplanter-infrastructure/actions/workflows/ci.yml)
[![Docs](https://img.shields.io/badge/docs-nolte.github.io%2Fkamerplanter--infrastructure-blue)](https://nolte.github.io/kamerplanter-infrastructure/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-planning-orange.svg)](#)

Terraform modules and scripts that provision the [Kamerplanter Appliance](https://github.com/nolte/kamerplanter-appliance) at different hosting providers.

The appliance image is built in [`nolte/kamerplanter-appliance`](https://github.com/nolte/kamerplanter-appliance). This repository takes that image and brings it up as a running machine at a provider: it creates the server or virtual machine, its network and storage, and hands the appliance its first-boot configuration.

> **Status: planning.** Only Proxmox VE has modules so far, and they are untested against a real appliance image, because `kamerplanter-appliance` has not published a release yet. Sections marked *planned* are not implemented.

## Goals

- **One module per provider.** Each target has its own self-contained Terraform module with a small, similar set of inputs and outputs.
- **Same appliance everywhere.** The modules deploy the published appliance image unchanged. Behaviour of the appliance lives in `kamerplanter-appliance`, behaviour of the application in [`nolte/kamerplanter`](https://github.com/nolte/kamerplanter), never here.
- **Scripts where Terraform doesn't fit.** Steps that a provider doesn't expose through Terraform, such as uploading or importing an image, are small scripts next to the module that needs them.
- **Minimal input.** A deployment needs credentials for the provider, an SSH key, and a few sizing choices. Everything else has a sensible default.

## Non-goals

- Building the appliance image (see `kamerplanter-appliance`).
- Configuring or developing the Kamerplanter services (see `kamerplanter`).
- High availability, clustering, or managed Kubernetes platforms. For those, use the upstream [Helm chart](https://github.com/nolte/kamerplanter/tree/develop/helm).

## Providers

| Provider | Kind | Status |
|----------|------|--------|
| Hetzner Cloud | Hosted server | planned |
| OVHcloud | Hosted server | planned |
| Proxmox VE | Private virtualisation | in progress |
| AWS | Public cloud | later |
| Microsoft Azure | Public cloud | later |
| Google Cloud | Public cloud | later |

Small private hardware such as a mini PC needs no infrastructure code: the appliance image is written to a USB stick and booted directly.

## Layout

```text
src/
├── modules/                       # Reusable Terraform modules
│   ├── proxmox-appliance-image/   # Download the appliance image onto a Proxmox VE datastore
│   └── proxmox-appliance-vm/      # Create the appliance VM from that image
└── scripts/                       # Ready-to-use root configurations per provider
    └── proxmox/
```

Modules for further providers follow the same pattern: `src/modules/<provider>-appliance-*` for the reusable parts, `src/scripts/<provider>/` for the example that wires them together.

## Usage

Each provider gets a ready-to-use configuration under `src/scripts/<provider>/`. For Proxmox VE, see [`src/scripts/proxmox`](src/scripts/proxmox/README.md):

```bash
cd src/scripts/proxmox
cp terraform.tfvars.example terraform.tfvars   # set node, release, checksum, SSH key
terraform init
terraform apply
```

After `apply`, the configuration outputs the address of the appliance. Open it in a browser to reach the Kamerplanter web UI.

Use the modules from your own Terraform configuration:

```hcl
module "image" {
  source = "github.com/nolte/kamerplanter-infrastructure//src/modules/proxmox-appliance-image?ref=<version>"

  node_name = "pve"
  image_url = "https://github.com/nolte/kamerplanter-appliance/releases/download/<version>/disk.raw"
  file_name = "kamerplanter-appliance-<version>.raw"
  checksum  = "<sha256>"
}

module "appliance" {
  source = "github.com/nolte/kamerplanter-infrastructure//src/modules/proxmox-appliance-vm?ref=<version>"

  node_name       = "pve"
  image_file_id   = module.image.file_id
  ssh_public_keys = ["ssh-ed25519 AAAA..."]
}
```

Pin `ref` to a released version rather than a branch.

## Requirements

- [Terraform](https://developer.hashicorp.com/terraform) or [OpenTofu](https://opentofu.org/)
- An account and API credentials at the chosen provider
- An SSH key pair for administrative access

The Proxmox VE modules use the [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox) provider and need Proxmox VE 8.4 or later.

## Development

Development needs [Task](https://taskfile.dev), Python 3, and the Terraform and TFLint versions pinned in `.tool-versions`.

```bash
task setup   # project-local venv, pre-commit, docs toolchain, git hooks
task check   # lint (terraform fmt/validate, tflint, yamllint), terraform test, docs build
```

`task test` runs the module tests in `tests/` against a mocked Proxmox provider, so no Proxmox VE node is needed.

## Related repositories

| Repository | Purpose |
|------------|---------|
| [`nolte/kamerplanter`](https://github.com/nolte/kamerplanter) | The application: backend, frontend, Helm chart |
| [`nolte/kamerplanter-appliance`](https://github.com/nolte/kamerplanter-appliance) | The bootable appliance image |
| `nolte/kamerplanter-infrastructure` | This repository: provisioning the appliance at providers |
