# Audiences — Kamerplanter Infrastructure

<!--
Produced via the `audience-identify` skill, following
spec/project/audience-identification/. Audiences, categories, ranking, tracks
and status were chosen by the maintainer on 2026-11-13; expectations and
surfaces are derived from README.md, CLAUDE.md, src/ and docs/. Do not add
audiences without first declaring the bounded context below.
-->

## Bounded context

The Terraform modules and example configurations that provision the Kamerplanter
appliance at hosting providers, starting with Proxmox VE.

**Inside the boundary**

- The reusable modules under `src/modules/` (`proxmox-appliance-image`,
  `proxmox-appliance-vm`, later one set per provider)
- The ready-to-use root configurations under `src/scripts/`
- The module interface: input variables, outputs, and the required Terraform
  and provider versions
- The module tests (`tests/`), the documentation (`docs/`), the specifications
  (`spec/`), and the CI and release workflows

**Outside the boundary**

- The appliance image itself (`nolte/kamerplanter-appliance`, with its own
  `AUDIENCES.md`)
- The Kamerplanter application (`nolte/kamerplanter`)
- The Kubernetes / Helm way of running Kamerplanter
- The operator's Proxmox VE node, datastores, or hosting account
- The Terraform providers themselves (for example `bpg/proxmox`)

## Audiences

Each entry: label, relationship category, interaction surface, expectation,
documentation `track` (`user-docs` or `developer-docs` per
spec/project/docs-audience-tracks/), open questions, `confirmed` or `assumed`,
criticality (primary / secondary / peripheral).

Portfolio-baseline track defaults: `user` → `user-docs`; `contributor` /
`operator` / `release-manager` → `developer-docs`.

### Direct consumers

- **Self-hoster** (ID `self-hoster`) — _category_: direct-consumer ·
  _surface_: the example configuration `src/scripts/<provider>/`
  (`terraform.tfvars.example`, `terraform apply`), provider credentials from
  environment variables, the outputs (VM ID, address, web UI URL) ·
  _expects_: a working appliance from a copied `tfvars` file and an API token,
  a verified image download, sensible defaults for sizing and network, a newer
  appliance release never replacing the running VM and its data ·
  _track_: `user-docs` · _status_: `confirmed` · _criticality_: primary
  - Open questions: which Proxmox VE privileges the API token needs at minimum;
    how the self-hoster learns the appliance address when DHCP is used without
    the guest agent.

- **Terraform author** (ID `terraform-author`) — _category_: direct-consumer ·
  _surface_: the modules under `src/modules/` referenced by Git URL with
  `?ref=<version>`, their variables, validations, and outputs ·
  _expects_: stable variable and output names, breaking changes only with a
  major version and named in the release notes, documented provider and
  Terraform / OpenTofu version requirements ·
  _track_: `developer-docs` · _status_: `assumed` · _criticality_: secondary
  - Open questions: whether OpenTofu is tested or only expected to work.

### Operators

- none — the self-hoster operates the deployment it creates and is listed
  under direct consumers; a separate Proxmox VE administrator who only grants
  access was considered and not selected.

### Contributors / maintainers

- **Maintainer (`nolte`)** (ID `maintainer`) — _category_: contributor ·
  _surface_: the repository (`src/`, `tests/`, `.github/`), Renovate updates of
  Terraform, TFLint, and providers, CI and the release workflows ·
  _expects_: green CI with mocked-provider tests, reviewable provider bumps,
  releases that state what changed in the module interface ·
  _track_: `developer-docs` · _status_: `confirmed` · _criticality_: secondary
- External contributors: none yet — no outside changes have been submitted.

### Governing parties

- **Terms of the hosting providers** — _category_: governing ·
  _surface_: the rules of Hetzner, OVHcloud and the large cloud providers on
  custom images and publicly reachable services ·
  _expects_: modules that stay within self-service and import images only where
  the provider allows it ·
  _track_: `developer-docs` · _status_: `assumed` · _criticality_: secondary

- **Licences** — _category_: governing ·
  _surface_: the MIT licence of this repository; the licences of the providers
  the modules depend on (for example MPL-2.0 for `bpg/proxmox`) ·
  _expects_: a licence file in the repository, dependencies used under their
  terms ·
  _track_: `developer-docs` · _status_: `assumed` · _criticality_: secondary

### Indirect audiences

- **Kamerplanter appliance project** (`nolte/kamerplanter-appliance`) —
  _category_: indirect ·
  _surface_: release asset names, checksums, and the provisioning interface
  (cloud-init) the modules rely on ·
  _expects_: the modules deploy the published image unchanged and report
  mismatches upstream instead of working around them ·
  _track_: `developer-docs` · _status_: `assumed` · _criticality_: peripheral
  - Open questions: final asset name and format of the disk image; whether the
    appliance accepts cloud-init.

- **Kamerplanter users** — _category_: indirect ·
  _surface_: the web UI of an appliance provisioned with these modules ·
  _expects_ (without knowing): the service stays available and keeps its data
  across infrastructure changes ·
  _track_: `user-docs` · _status_: `assumed` · _criticality_: peripheral
  - Open questions: none — their documentation lives upstream.

## Open questions (cross-cutting)

- The appliance has not published a release yet, so asset names and the
  provisioning interface are unconfirmed for every audience above.

## Revisit triggers

Re-run `audience-identify revisit` when any of the following changes:

- Modules for a further provider (Hetzner, OVHcloud, a public cloud) land.
- The modules are published to a Terraform registry.
- External contributors start submitting changes.
- Someone provisions appliances for others (a managed or shared offering).
