# Proxmox bootc template registration

## Assumptions

- The qcow2 already exists on `nodeF` at
  `/mnt/pve/cFS/import/rhel10-bootc-20260606.1.qcow2`.
- The qcow2 checksum is
  `5efb97c95c9ce3045994551da3b9e5bda94a4100aefdb337922de6066d8d1b7c`.
- `nodeF` has active access to Proxmox storage `cephVM`.
- `pve_template_node` is supplied at runtime and is currently expected to be
  `nodeF`.
- VMID `9001` is free or already belongs to
  `rhel10-bootc-20260606-1-tmpl`.
- Proxmox credentials remain outside git. Use 1Password `d3HLPRV` references
  only.

## Candidate config

The playbook creates or rebuilds one template VM:

- VMID: `9001`
- Name: `rhel10-bootc-20260606-1-tmpl`
- Machine: `q35`
- BIOS: `ovmf`
- Disk bus: `virtio-scsi`
- NIC: `virtio,bridge=vmbr0`
- Storage: `cephVM`
- Cloud-init drive: `ide2: cephVM:cloudinit`
- Boot order: `scsi0`

## Read-only preflight

Run this Ansible read-only preflight before the live playbook. The checked-in
env-file example contains only `d3HLPRV` references:

```text
PROXMOX_SSH_USER=d3
PROXMOX_SSH_PASSWORD=op://d3HLPRV/proxmox_env/password
```

```bash
op run --env-file ansible/op-run.proxmox.example -- \
  ansible-playbook -i ansible/inventories/proxmox-first.yml \
  ansible/playbooks/preflight_proxmox_template.yml \
  -e pve_template_node=nodeF
```

If `qm config 9001` returns a VM with a different name, choose another VMID and
record it before running the playbook.

## Live registration

Run only after recording approval for the single-template mutation:

```bash
op run --env-file ansible/op-run.proxmox.example -- \
  ansible-playbook -i ansible/inventories/proxmox-first.yml \
  ansible/playbooks/register_bootc_proxmox_template.yml \
  -e pve_template_node=nodeF
```

Override values when needed:

```bash
op run --env-file ansible/op-run.proxmox.example -- \
  ansible-playbook -i ansible/inventories/proxmox-first.yml \
  ansible/playbooks/register_bootc_proxmox_template.yml \
  -e pve_template_node=nodeF \
  -e pve_template_vmid=9002 \
  -e pve_template_name=rhel10-bootc-20260606-1-tmpl \
  -e pve_ceph_storage=cephVM \
  -e pve_template_bridge=vmbr0
```

## Validation commands

```bash
qm config 9001
qm list | grep rhel10-bootc-20260606-1-tmpl
```

Expected config signals:

- `template: 1`
- `bios: ovmf`
- `machine: q35`
- `scsihw: virtio-scsi-single`
- `net0: virtio=...,bridge=vmbr0`
- `ide2: cephVM:cloudinit`
- `boot: order=scsi0`

For a boot validation, clone the template, supply cloud-init hostname, IP
settings, and SSH keys, then confirm:

```bash
qm clone 9001 <test-vmid> --name rhel10-bootc-test --full 1
qm set <test-vmid> --ciuser d3 --sshkeys <public-key-file>
qm start <test-vmid>
ssh d3@<test-ip> true
```

## Rollback hints

- If the playbook fails before `qm template`, inspect and remove only the target
  VMID: `qm destroy 9001 --purge --skiplock`.
- If the clone test fails, keep the template intact and collect
  `qm config 9001`, clone console output, and cloud-init logs from the clone.
- Do not delete unrelated VMIDs or change Ceph pool settings as part of this
  runbook.
