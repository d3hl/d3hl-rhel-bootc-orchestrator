# proxmox-bootc-vm module

Proxmox-first bootc VM contract, expressed with the **bpg/proxmox** Terraform
provider (preferred over `telmate/proxmox`).

Rules:

- Provider is pinned in `required_providers` (`source = "bpg/proxmox"`, `version = "~> 0.109"`).
- No live provider configuration in this feature: no `provider {}` block, endpoints,
  or credentials in `.tf`. Auth is supplied via Terraform variables and HCP Terraform
  workspace variable sets at apply time.
- Variables carry `validation` blocks.
- Networking is described by `network_bridge` / `network_vlan_id` variables; the live
  `network_device` block is added when networking is wired.
- Keep HCP Terraform remote execution and state behavior documented before live plan/apply.

Verified by `terraform fmt -check`, `terraform init -backend=false`, and
`terraform validate` (see TF-001 evidence).
