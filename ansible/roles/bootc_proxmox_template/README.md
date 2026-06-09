# bootc_proxmox_template

Registers the staged RHEL bootc qcow2 as a Ceph-backed Proxmox VM template.

## Required runtime variable

- `pve_template_node`: inventory host for the Proxmox node that owns template
  builds. This is intentionally not defaulted.

## Default variables

- `pve_qcow2_path`: `/mnt/pve/cFS/import/rhel10-bootc-20260606.1.qcow2`
- `pve_qcow2_sha256`: `5efb97c95c9ce3045994551da3b9e5bda94a4100aefdb337922de6066d8d1b7c`
- `pve_template_vmid`: `9001`
- `pve_template_name`: `rhel10-bootc-20260606-1-tmpl`
- `pve_ceph_storage`: `cephVM`
- `pve_template_bridge`: `vmbr0`
- `pve_template_memory_mb`: `4096`
- `pve_template_cores`: `2`
- `pve_template_destroy_existing`: `true`
- `pve_template_allow_replace_any`: `false`
- `pve_template_remove_qcow2_after_import`: `false`

The role refuses to replace an existing VMID unless the existing VM name matches
`pve_template_name`, or `pve_template_allow_replace_any=true` is set after an
explicit approval record.

## Validation

```bash
ansible-playbook --syntax-check ansible/playbooks/register_bootc_proxmox_template.yml
```

Live registration requires a Proxmox inventory host and approval:

```bash
op run --env-file ansible/op-run.proxmox.example -- \
  ansible-playbook -i ansible/inventories/proxmox-first.yml \
  ansible/playbooks/register_bootc_proxmox_template.yml \
  -e pve_template_node=nodeF
```

Run read-only preflight through the same Ansible SSH/become path first:

```bash
op run --env-file ansible/op-run.proxmox.example -- \
  ansible-playbook -i ansible/inventories/proxmox-first.yml \
  ansible/playbooks/preflight_proxmox_template.yml \
  -e pve_template_node=nodeF
```

The env file contains only `d3HLPRV` 1Password references, not plaintext
secrets. Do not use Proxmox API credentials for live template registration.
