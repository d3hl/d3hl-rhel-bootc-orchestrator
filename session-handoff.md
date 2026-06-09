# Session handoff

Last updated: 2026-06-09

## Current Task

bootc OCI image converted to qcow2. Proxmox VM template registration automation
is implemented and live-verified as VMID `9001` on `nodeF`. Next feature:
`TF-001`.

## Artifact summary

| Field | Value |
|-------|-------|
| OCI image | `satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab:rhel10-bootc-20260606.1` |
| OCI digest | `sha256:0efcf2d0b0144bd166165cb4b408517cd134652792b4a2352b8fe39fb821ed21` |
| qcow2 | `nodeF:/mnt/pve/cFS/import/rhel10-bootc-20260606.1.qcow2` (~1.3 GiB) |
| qcow2 sha256 | `5efb97c95c9ce3045994551da3b9e5bda94a4100aefdb337922de6066d8d1b7c` |

## Files Touched

- `images/templates/config.toml.j2`
- `ansible/playbooks/convert_bootc_to_qcow2.yml`
- `ansible/playbooks/preflight_proxmox_template.yml`
- `ansible/playbooks/register_bootc_proxmox_template.yml`
- `ansible/inventories/proxmox-first.yml`
- `ansible/roles/bootc_proxmox_template/defaults/main.yml`
- `ansible/roles/bootc_proxmox_template/tasks/main.yml`
- `ansible/roles/bootc_proxmox_template/README.md`
- `images/validation-checklist.md`
- `docs/runbooks/proxmox-bootc-template.md`
- `docs/codex-handoff-proxmox-vm-template.md`
- `feature_list.json`
- `session-handoff.md`
- `claude-progress.md`

## Verification

- Passed: `bootc-image-builder` produced `/tmp/bootc-qcow2-out/qcow2/disk.qcow2`
- Passed: staged qcow2 at `/var/tmp/rhel10-bootc-20260606.1.qcow2` on the build host; current target path is `nodeF:/mnt/pve/cFS/import/rhel10-bootc-20260606.1.qcow2`
- Passed: `ansible-playbook --syntax-check ansible/playbooks/register_bootc_proxmox_template.yml`
- Passed: `ansible-playbook ansible/playbooks/register_bootc_proxmox_template.yml` failed safely at the localhost assertion when `pve_template_node` was omitted, before any Proxmox command could run
- Passed: `./init.sh` from `/home/d3/Github/d3hl-rhel-bootc-orchestrator`
- Historical evidence: API-first Proxmox preflight with `op://d3HLPRV/proxmox_env/PROXMOX_API_TOKEN` confirmed API version `9.2.3`, `nodeF` online, VMID `9001` absent cluster-wide, and no `nodeF` config file for VMID `9001`
- Passed: corrected API storage ID `cephVM` is active and enabled on `nodeF` with `rootdir,images` content
- Passed: Ansible read-only preflight over SSH/become from `ansible/op-run.proxmox.example` confirmed `cephVM` active, qcow2 checksum `5efb97c95c9ce3045994551da3b9e5bda94a4100aefdb337922de6066d8d1b7c`, and VMID `9001` config rc `2`
- Passed: first live registration attempt failed safely before mutation due an undefined absent-VMID guard fact; guard was fixed by defaulting `pve_existing_vm_name` to empty when `qm config` returns non-zero
- Passed: live registration with `op run --env-file ansible/op-run.proxmox.example -- ansible-playbook -i ansible/inventories/proxmox-first.yml ansible/playbooks/register_bootc_proxmox_template.yml -e pve_template_node=nodeF` created VMID `9001`, imported qcow2 into `cephVM`, attached `scsi0` and `ide2`, set boot order, and converted the VM to a template
- Passed: `qm config 9001` confirmed `template: 1`, `bios: ovmf`, `machine: q35`, `scsihw: virtio-scsi-single`, `scsi0: cephVM:base-9001-disk-1`, `ide2: cephVM:vm-9001-cloudinit,media=cdrom`, `boot: order=scsi0`, and name `rhel10-bootc-20260606-1-tmpl`
- Passed: `qm list` on `nodeF` shows VMID `9001` as `rhel10-bootc-20260606-1-tmpl`
- Pending: final `./init.sh` after evidence updates, Linear sync to Done, then `TF-001`

## Blockers / Risks

- qcow2 is root-owned (`0600`) on build host; Proxmox import playbook must run
  with privileges on the target node or copy via Ansible become.
- `config.toml` `/var` filesystem customization is invalid on RHEL 10; template
  updated to root-only + kernel table syntax.
- Registry push still blocked earlier by satellite auth; local OCI image was used.
- `pve_template_node` is `nodeF`; VMID `9001` is free by API preflight.
- The documented/default storage ID `ceph-vm` is wrong for this cluster; use
  `cephVM` unless the Proxmox storage configuration changes.
- Live registration was intentionally Ansible SSH/CLI-based. Do not implement or
  run a Proxmox API mutation path for this feature.
- Future rebuilds must remain gated behind explicit approval because the role can
  destroy and recreate VMID `9001` when it matches the expected template name.
- The role refuses to replace an existing VMID with a different name unless
  `pve_template_allow_replace_any=true` is explicitly set after approval.

## Next Session Command

```bash
cd /home/d3/Github/d3hl-rhel-bootc-orchestrator
sed -n '1,260p' docs/runbooks/proxmox-bootc-template.md
./init.sh
```

## Linear sync notes

Team **d3HL**. Project **Ansible Automation Orchestrator**.

| Harness | Linear | State (2026-06-07) |
|---------|--------|---------------------|
| BOOTC-000 | NCD-20 | Done |
| ARCH-001 | NCD-21 | Done |
| REGISTRY-001 | NCD-22 | Done |
| IMAGE-001 | NCD-24 | Done |
| PVE-TEMPLATE-001 | NCD-29 | Done |
| TF-001 | NCD-23 | Todo |
| ANSIBLE-001 | NCD-25 | Todo |
| CI-001 | NCD-26 | Backlog |
| E2E-001 | NCD-27 | Todo |

## Codex entrypoint

Start `TF-001`. Use only `op://d3HLPRV/...` secret references through `op run`;
do not modify `d3hl-infra-bootc-pipeline`.
