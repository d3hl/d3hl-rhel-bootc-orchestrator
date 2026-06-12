# d3hl-rhel-bootc-orchestrator progress

Last updated: 2026-06-12

## Current Verified State

- New project harness exists for an Ansible-first RHEL image-mode / bootc orchestration platform.
- First deployment target: Proxmox.
- Live infrastructure actions are intentionally out of scope for the initial harness.
- `BOOTC-000` static baseline passed on 2026-06-04.
- `ARCH-001` architecture ADR accepted on 2026-06-06 (`docs/architecture/0001-ansible-first-bootc-flow.md`).
- `REGISTRY-001` registry contract accepted on 2026-06-07 (`registry/README.md`).
- `IMAGE-001` bootc image build inputs accepted on 2026-06-07 (`images/README.md`, `images/validation-checklist.md`, Ansible render role/playbook).
- `PVE-TEMPLATE-001` Proxmox template registration accepted on 2026-06-09 (`ansible/playbooks/register_bootc_proxmox_template.yml`, `ansible/playbooks/preflight_proxmox_template.yml`, `ansible/roles/bootc_proxmox_template/`, `docs/runbooks/proxmox-bootc-template.md`).
- Linear dual-layer workflow documented in `agent-contract-master/docs/linear-workflow.md`.
- Bootc Linear issues backfilled (NCD-20 through NCD-27); ARCH-001 synced as Done (NCD-21).
- `TF-001` HCP Terraform Proxmox-first provisioning contract scaffolded and passing on 2026-06-12 (`terraform/environments/dev/`, `terraform/modules/proxmox-bootc-vm/`) using the preferred `bpg/proxmox` provider pinned `~> 0.109`; no live apply and no provider credentials in repo `.tf`.

## Current Objective

`TF-001` complete. Next: pick the highest-priority unfinished feature in `feature_list.json` and keep live HCP Terraform plan/apply out of scope until explicitly approved.

## Verification Evidence

- 2026-06-04 `./init.sh` passed from `/home/d3/Github/d3hl-rhel-bootc-orchestrator`.
- 2026-06-06 `./init.sh` passed after ADR 0001 and harness updates.
- 2026-06-07 `./init.sh` passed after `REGISTRY-001` contract updates.
- 2026-06-07 `images/` defines Containerfile and operator templates for user `d3` with `wheel` group, `ALL=(ALL:ALL) NOPASSWD:ALL` sudo, and SSH key reference `op://d3HLPRV/d3_ops/public key`; `ansible/playbooks/render_bootc_image_context.yml` renders build context Ansible-first; `ansible-playbook --syntax-check` and `op run` render to `/tmp/bootc-build-test` passed; `./init.sh` passed.
- 2026-06-07 `bootc-image-builder` converted `rhel10-bootc-20260606.1` to qcow2 (`5efb97c95c9ce3045994551da3b9e5bda94a4100aefdb337922de6066d8d1b7c`); staged at `/var/tmp/rhel10-bootc-20260606.1.qcow2` on the build host, then current target staging moved to `nodeF:/mnt/pve/cFS/import/rhel10-bootc-20260606.1.qcow2`; Codex handoff written to `docs/codex-handoff-proxmox-vm-template.md`.
- 2026-06-07 `ansible/playbooks/register_bootc_proxmox_template.yml` and `ansible/roles/bootc_proxmox_template/` implemented Proxmox template registration for the staged qcow2 with defaults `pve_template_vmid=9001`, `pve_template_name=rhel10-bootc-20260606-1-tmpl`, `pve_ceph_storage=cephVM`, q35, OVMF, virtio-scsi, virtio NIC, and cloud-init drive. `ansible-playbook --syntax-check ansible/playbooks/register_bootc_proxmox_template.yml` passed. `ansible-playbook ansible/playbooks/register_bootc_proxmox_template.yml` failed safely before Proxmox mutation because `pve_template_node` was omitted. `./init.sh` passed from `/home/d3/Github/d3hl-rhel-bootc-orchestrator`.
- 2026-06-08 user selected `nodeF` for `pve_template_node` and identified Proxmox secrets at `op://d3HLPRV/proxmox_env/`. Initial read-only preflight could not complete: SSH to `nodeF`/`10.10.10.10` with `username`/`password` returned permission denied for all commands; `PROXMOX_API_TOKEN` authenticated to Proxmox `9.2.3` but returned HTTP 403 for `ceph-vm` storage status and VMID `9001` config; API ticket auth with `username`/`password` returned HTTP 401. No live Ansible template registration was run.
- 2026-06-08 API-first preflight rerun with `op://d3HLPRV/proxmox_env/PROXMOX_API_TOKEN`: Proxmox API version read succeeded (`9.2.3`), `nodeF` is online, VMID `9001` was not present in cluster resources, and `/nodes/nodeF/qemu/9001/config` returned no config file. Storage preflight showed the documented/default ID `ceph-vm` does not exist; API-visible RBD storage is `cephVM`, active and enabled on `nodeF` with `rootdir,images` content. Live registration was not run.
- 2026-06-09 `ansible/playbooks/preflight_proxmox_template.yml` added an Ansible SSH/become read-only preflight for `nodeF`, `cephVM`, VMID `9001`, and the staged qcow2 checksum. `ansible/inventories/proxmox-first.yml` now defines `nodeF` with runtime `PROXMOX_SSH_USER`/`PROXMOX_SSH_PASSWORD` environment variables that must be populated by `op run` from `d3HLPRV`.
- 2026-06-09 `op run --env-file ansible/op-run.proxmox.example -- ansible-playbook -i ansible/inventories/proxmox-first.yml ansible/playbooks/preflight_proxmox_template.yml -e pve_template_node=nodeF` passed with no changes: `cephVM` active, qcow2 path `/mnt/pve/cFS/import/rhel10-bootc-20260606.1.qcow2`, sha256 `5efb97c95c9ce3045994551da3b9e5bda94a4100aefdb337922de6066d8d1b7c`, and VMID `9001` config rc `2`.
- 2026-06-09 first live registration attempt failed safely before Proxmox mutation because the VMID guard referenced `pve_existing_vm_name` when VMID `9001` was absent; `ansible/roles/bootc_proxmox_template/tasks/main.yml` now defaults that fact to an empty string when `qm config` returns non-zero.
- 2026-06-09 `op run --env-file ansible/op-run.proxmox.example -- ansible-playbook -i ansible/inventories/proxmox-first.yml ansible/playbooks/register_bootc_proxmox_template.yml -e pve_template_node=nodeF` passed: VMID `9001` created on `nodeF`, qcow2 imported into `cephVM`, `scsi0` attached, cloud-init drive attached, boot order set to `scsi0`, and `qm template 9001` applied.
- 2026-06-09 post-check `qm config 9001` confirmed `template: 1`, `bios: ovmf`, `machine: q35`, `scsihw: virtio-scsi-single`, `scsi0: cephVM:base-9001-disk-1`, `ide2: cephVM:vm-9001-cloudinit,media=cdrom`, `boot: order=scsi0`, and name `rhel10-bootc-20260606-1-tmpl`.
- 2026-06-09 `qm list` on `nodeF` shows VMID `9001` as `rhel10-bootc-20260606-1-tmpl` stopped with 4096 MB memory and 10 GB boot disk.
- 2026-06-09 `./init.sh` passed from `/home/d3/Github/d3hl-rhel-bootc-orchestrator` after Ansible-first preflight and `d3HLPRV` secret-reference updates; rerun after live evidence is still required before commit.
- `registry/README.md` documents `sudo podman`, `satellite.d3hl.site`, base image `satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab:rhel10-bootc`, username `aap`, and password reference `op://d3HLPRV/Rhel Satelite/PAT for mcp`.
- Terraform dev environment validated successfully.
- Ansible checks skipped because `ansible-playbook` and `ansible-lint` are not installed locally.
- Git whitespace check completed.
- 2026-06-12 `TF-001`: `terraform fmt -check -recursive terraform` rc 0; `terraform init -backend=false` + `validate` succeeded for `terraform/environments/dev` and `terraform/modules/proxmox-bootc-vm` (provider `bpg/proxmox` 0.109.0 resolved from registry); `./init.sh` passed rc 0.

## Blockers / Risks

- HCP Terraform, AAP, Quay/private registry, Red Hat subscription, and Proxmox credentials must remain references only.
- Live integration must remain gated behind explicit approval and recorded pre-check evidence.
- `d3HLPRV` is the only approved 1Password vault for this repo's documented secret references.
- `cloud-init` and `qemu-guest-agent` package installs require RH entitlement on the build host; operator profile is baked at image build time instead.
- Proxmox API token scope was sufficient for earlier read-only node, storage, and VMID evidence, but live registration was completed through the Ansible SSH/CLI path with 1Password `d3HLPRV` SSH/become references.
- `PVE-TEMPLATE-001` is implemented and live-verified; do not rerun with `pve_template_allow_replace_any=true` unless a future rebuild is explicitly approved.
- Linear sync 2026-06-09: NCD-29 moved to Done with live `qm config 9001` evidence. Repo harness remains authoritative.

## Recommended Next Step

Run `./init.sh` again, mark `PVE-TEMPLATE-001` passing in Linear if not already
synced, then start `TF-001` for the HCP Terraform Proxmox-first provisioning
contract.
