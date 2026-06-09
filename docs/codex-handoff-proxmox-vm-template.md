# Codex handoff — Proxmox VM template from bootc qcow2

Handoff format follows `d3hl-infra-bootc-pipeline/docs/handoff-format.md`.

## Intent

Register the converted RHEL 10 bootc qcow2 as a Proxmox VM template so the
homelab can clone immutable bootc VMs from a blessed disk image.

## Upstream artifact (already produced)

| Field | Value |
|-------|-------|
| OCI image | `satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab:rhel10-bootc-20260606.1` |
| OCI digest | `sha256:0efcf2d0b0144bd166165cb4b408517cd134652792b4a2352b8fe39fb821ed21` |
| qcow2 path (nodeF) | `/mnt/pve/cFS/import/rhel10-bootc-20260606.1.qcow2` |
| qcow2 sha256 | `5efb97c95c9ce3045994551da3b9e5bda94a4100aefdb337922de6066d8d1b7c` |
| qcow2 size | ~1.3 GiB |
| Operator user baked in image | `d3` (`wheel`, passwordless sudo) |
| Conversion tool | `registry.redhat.io/rhel9/bootc-image-builder:latest` |
| Conversion config | empty `config.toml` (RHEL 10 rejected `/var` mount customization) |

Do not rebuild or reconvert unless acceptance criteria fail. Start from the staged
qcow2 above.

## Files in scope

- `ansible/playbooks/register_bootc_proxmox_template.yml` (new)
- `ansible/roles/bootc_proxmox_template/` (new: defaults, tasks, README)
- `ansible/inventories/proxmox-first.yml`
- `docs/runbooks/proxmox-bootc-template.md` (new)
- `session-handoff.md`
- `claude-progress.md`

Read-only references (do not modify):

- `d3hl-infra-bootc-pipeline/playbooks/register_template_ceph.yml`
- `d3hl-infra-bootc-pipeline/docs/architecture/0002-ceph-rbd-for-template-storage.md`

## Acceptance criteria

- Playbook imports `/mnt/pve/cFS/import/rhel10-bootc-20260606.1.qcow2` into Proxmox Ceph
  storage and converts the VM to a template.
- Template uses **UEFI** (`ovmf`), **q35**, **virtio-scsi**, **virtio NIC**,
  and a **cloud-init drive** attached for per-VM hostname/IP/SSH injection.
- Default template variables are documented and overridable:
  - `pve_template_vmid` default `9001`
  - `pve_template_name` default `rhel10-bootc-20260606-1-tmpl`
  - `pve_ceph_storage` default `cephVM`
  - `pve_template_node` required at runtime; current target is `nodeF`
- Playbook is idempotent enough to rebuild the template VMID safely
  (`qm destroy --purge` then recreate) without touching unrelated VMs.
- `ansible-playbook --syntax-check ansible/playbooks/register_bootc_proxmox_template.yml`
  passes.
- Runbook documents validation commands:
  - `qm config <vmid>`
  - `qm template <vmid>` already applied
  - test clone boots and SSH as `d3` works with cloud-init supplied keys
- No plaintext secrets in git. Proxmox SSH/become credentials remain
  `op://d3HLPRV/...` references only.

## Blast radius

- Creates or replaces **one** template VMID on the chosen Proxmox node.
- Writes one qcow2 import into `cephVM` (or configured storage pool).
- Does **not** change network VLANs, FortiGate, Cloudflare, or unrelated VMIDs.
- Does **not** modify `d3hl-infra-bootc-pipeline` or `d3hl-managed-proxmox`.

## Out of scope

- HCP Terraform workspace apply
- AAP workflow import or job launch
- Rebuilding the OCI image or rerunning bootc-image-builder
- Promoting registry tags
- Production fleet rollout / mass clone
- Changing Ceph pool layout or storage policy

## Body

The OCI image was built from `IMAGE-001` templates with operator `d3` baked in.
`bootc-image-builder` produced a qcow2 on the build host WSL environment. The
next lifecycle step is Proxmox template registration.

Use the existing Ceph-backed pattern from `register_template_ceph.yml`:

1. Verify target storage is active.
2. Destroy existing template VMID if present.
3. Create q35/OVMF VM shell with serial console and guest agent enabled.
4. `qm disk import` the staged qcow2 into Ceph as raw.
5. Attach scsi0, add cloud-init drive, set boot order.
6. `qm template` to finalize.

Assumptions to confirm at runtime (document in runbook, do not guess silently):

- Which Proxmox node owns template builds (`pve_template_node`) — current target
  is `nodeF` with `cephVM` active.
- Bridge name for NIC (`vmbr0` unless inventory says otherwise).
- Whether template VMID `9001` is free on the cluster.

Registry auth for future rebuilds uses `op://d3HLPRV/Redhat Registry/username`
and `password` for `registry.redhat.io` bootc-image-builder pulls. Satellite
registry auth remains separate.

## ADR reference

- `docs/architecture/0001-ansible-first-bootc-flow.md`
- Reference only: `d3hl-infra-bootc-pipeline/docs/architecture/0002-ceph-rbd-for-template-storage.md`

## Test additions

- Syntax-check both new playbooks:
  - `convert_bootc_to_qcow2.yml`
  - `register_bootc_proxmox_template.yml`
- Dry-run / check mode is not required for Proxmox CLI tasks, but run the
  Ansible read-only preflight before live registration.

## Migration notes

If VMID `9001` is already used by another template, pick a new VMID and record it
in the runbook and inventory group vars. Do not overwrite an unrelated template.

## Codex response checklist

Respond using the standard structure from `handoff-format.md`:

- What I changed
- Gates run
- Evidence (include `qm config` output for the new template)
- Surprises
- PR link
