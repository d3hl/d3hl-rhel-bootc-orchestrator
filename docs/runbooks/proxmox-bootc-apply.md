# Proxmox bootc VM provisioning (HCP Terraform apply)

Operator runbook for the **live** `terraform apply` of the dev bootc VMs defined
in `terraform/environments/dev/`. Provisioning only — OS/day-2 configuration is
Ansible's job (see `ansible/playbooks/bootc_provision.yaml`).

## Scope and gating

- Live apply is **gated**: per `AGENTS.md`, do not mutate HCP Terraform or
  Proxmox without explicit approval and recorded pre-check evidence. The
  `terraform plan` captured below **is** that evidence — keep it with the change.
- Execution is remote: `main.tf` uses an HCP Terraform `cloud {}` block, so
  `plan`/`apply` run in the HCP workspace, not on the operator host.
- Secrets are referenced only as `op://d3HLPRV/...` and live in HCP workspace
  variables, never in repo `.tf`.
- The `terraform/modules/proxmox-bootc-vm/` skeleton is **not** used by dev; the
  dev environment provisions directly via `proxmox-rhvm.tf` (for_each).

## Assumptions

- Template VMID `9001` (`rhel10-bootc-20260606-1-tmpl`) exists on `nodeF` with its
  disk on the shared `cephVM` datastore, so a full clone can land on other nodes.
- Target nodes `nodeA`, `nodeB`, `nodeD` are online and share `cephVM`.
- The snippets datastore `cFS` has the `snippets` content type enabled and is
  reachable on `nodeA`, `nodeB`, and `nodeD`.
- Network bridge `vsvc` exists on all three nodes.

## Candidate config (dev)

Provisions three VMs by full-clone of template `9001`:

| VM        | Node   | vCPU | Mem (MB) | Disk | Disk store | NIC bridge |
|-----------|--------|------|----------|------|------------|------------|
| `rhvm-01` | nodeA  | 4    | 16384    | 100G | cephVM     | vsvc       |
| `rhvm-02` | nodeB  | 4    | 16384    | 100G | cephVM     | vsvc       |
| `rhvm-03` | nodeD  | 4    | 16384    | 100G | cephVM     | vsvc       |

Cloud-init user-data is rendered from `cloudinit-user-data.yaml.tftpl` and
uploaded as a `cFS` snippet per VM (user `aap`, sudo NOPASSWD, SSH key from
`op://d3HLPRV/d3_ops/public key`).

## HCP Terraform workspace

- Organization: `ncdv` · Project: `bootc` · Workspace: `Komodo`
- Execution mode: **CLI-driven** (this runbook drives `plan`/`apply` locally
  against the remote workspace). Project assignment is in the repo's `cloud`
  block; confirm it matches the workspace in the HCP UI.

```bash
terraform login            # one-time: store an HCP user/team API token
```

## Workspace variables (set in HCP UI / variable set, never in repo)

Sensitive (mark **Sensitive**; resolve the `op://` value at entry time):

| Variable             | Kind      | Source                                   |
|----------------------|-----------|------------------------------------------|
| `proxmox_api_token`  | Terraform | `op://d3HLPRV/proxmox_env/PROXMOX_API_TOKEN` |
| `ci_ssh_public_key`  | Terraform | `op://d3HLPRV/d3_ops/public key`         |

Non-secret (only if overriding the committed defaults):

| Variable            | Default value (repo) |
|---------------------|----------------------|
| `proxmox_api_url`   | _none — must be set_ |
| `rhvm_storage`      | `cephVM`             |
| `rhvm_snippet_datastore` | `cFS`           |
| `rhvm_network_bridge`    | `vsvc`          |

- `proxmox_api_url`: the Proxmox API endpoint, e.g. `https://10.10.10.10:8006/`
  (the host used in the template preflight). Confirm the reachable endpoint.
- `proxmox_api_token` / `ci_ssh_public_key` carry placeholder `op://` defaults in
  `variables.tf`; the HCP workspace values **override** them. If a workspace
  value is missing, the run fails fast with the literal `op://...` string, which
  is the intended "you forgot to set it" signal.

## Read-only pre-check (capture as evidence)

1. **TLS / `insecure`** — `provider "proxmox"` in `main.tf` sets `insecure = false`.
   If the Proxmox API uses a self-signed cert not trusted by the HCP run
   environment, `plan` fails on TLS. Either trust the CA or set
   `insecure = true` (homelab) before applying.
2. **Snippets storage** — confirm `cFS` has `snippets` enabled on nodeA/B/D
   (`pvesm status` / Datacenter → Storage → cFS → Content includes *Snippets*).
3. **Template reachability** — confirm VMID `9001` is present and cloneable to the
   target nodes over shared `cephVM`.
4. **Terraform checks:**

```bash
terraform -chdir=terraform/environments/dev fmt -check
terraform -chdir=terraform/environments/dev init
terraform -chdir=terraform/environments/dev validate
terraform -chdir=terraform/environments/dev plan   # save output as pre-check evidence
```

## Apply

```bash
terraform -chdir=terraform/environments/dev apply   # review the plan, then confirm
```

(Or trigger the run and approve it in the HCP UI.)

## Post-apply

- Record the `rhvm_vms` output (name → node/VMID) and attach it to the change.
- Hand off to Ansible for OS configuration / registration via
  `ansible/playbooks/bootc_provision.yaml`, consuming the VM attributes/outputs.
- Update `claude-progress.md` and `feature_list.json` with the live evidence.

## Rollback

```bash
terraform -chdir=terraform/environments/dev destroy                       # all VMs
terraform -chdir=terraform/environments/dev destroy \
  -target='proxmox_virtual_environment_vm.rhvm["rhvm-03"]'                # one VM
```

Destroy also removes the cloud-init snippet files
(`proxmox_virtual_environment_file.cloudinit_user_data`). If a VM was created
outside Terraform state, remove it in Proxmox manually before re-running.
