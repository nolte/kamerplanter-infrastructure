# CLAUDE.md

Guidance for AI-assisted work in `kamerplanter-infrastructure`.

## What this repository is

Terraform modules and scripts that provision the [Kamerplanter Appliance](https://github.com/nolte/kamerplanter-appliance) at hosting providers. The appliance image itself is built in `nolte/kamerplanter-appliance`; application behaviour lives in `nolte/kamerplanter`. Neither belongs here.

## Layout

- `src/modules/<provider>-appliance-*/` — reusable Terraform modules, one concern each (e.g. image download, VM)
- `src/scripts/<provider>/` — example root configurations that wire the modules together
- `tests/` — `terraform test` root; each `*.tftest.hcl` loads one module via `run { module { source = "../src/modules/..." } }` against a mocked provider
- `docs/<lang>/` — MkDocs site (en canonical, de translation)
- `spec/` — requirements and decisions

## Commands

| Command | Purpose |
|---|---|
| `task setup` | Create `.venv`, install pre-commit and the docs toolchain, wire git hooks |
| `task fmt` | `terraform fmt -recursive` |
| `task lint` | All pre-commit hooks (terraform fmt/validate, tflint, yamllint) |
| `task test` | `terraform test` in `tests/` |
| `task docs` | `mkdocs build --strict` |
| `task check` | Quality gate: lint, test, docs |

Terraform and TFLint versions are pinned in `.tool-versions` (asdf); CI reads the same file.

## Conventions

- Provider: `bpg/proxmox` for Proxmox VE. Prefer its non-deprecated resource names (`terraform validate` warns).
- Every new module gets a test file in `tests/` and is used by an example in `src/scripts/`.
- Module variables carry `description`, `type`, and a `validation` block wherever bad input would only fail at apply time.
- Never let a newer appliance image replace an existing VM: the appliance updates itself and its disk holds user data.
- Credentials come from the environment (`PROXMOX_VE_*`), never from committed files. `*.tfvars` is gitignored; only `*.tfvars.example` is tracked.
- Branching: feature branches off `develop`; `main` is fast-forwarded on release.
