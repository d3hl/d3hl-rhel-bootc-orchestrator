# Session handoff

Last updated: 2026-06-18

## Current Task

`CEPH-MOUNT-001` (`passing`): CephFS `cFS` mounted at `/mnt/cfs` on all three
bootc_targets VMs. Root-cause chain fully resolved (see evidence in `feature_list.json`).
`ceph-rhel-keyring.service` enabled on each VM for boot-time kernel keyring population.

Next active feature: `ANSIBLE-001` — scaffold `bootc_provision` / `bootc_validate`
playbooks/roles against the now-reachable `bootc_targets` inventory with CephFS available.

## Artifact summary

| Field | Value |
|-------|-------|
| Quay image (zsh/git — current .4) | `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.4` |
| Quay image (zsh/git/ceph — .5) | `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.5` |
| `.5` pushed digest | `sha256:47640975df43a07099b9f2421ee5c87184daee1fbb7b444d70fcb38dd57e93e3` |
| `.4` pushed digest (zsh/git, no ceph) | `sha256:b9ef024ea924b174b6b5b7f50dd032dfd629908b1c57ac62f39e3a4fb5919a43` |
| `.4` prior digest (zsh/git/ceph — replaced) | `sha256:587737ee35f60fe147db78fadf2cfc3e9152f5a74ee6afc1df50f25ac213d0e4` |
| Quay image (via bootc_build role) | `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.3` |
| `.3` pushed digest | `sha256:5ed9875c30388e30d4d88c38e6c488e022c7b8d02c8515b9599f6ce8715071b9` |
| Quay image (with agent) | `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.2` |
| `.2` pushed digest | `sha256:57a2fa6dac8672f6ae20c18cb2edf160c048d494d5b3c695182914bd32e69aa9` |
| Quay image (no agent) | `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.1` |
| `.1` registry digest | `sha256:26fa41970ef519a3531ff18ac2cec6aeae0929840f159029fc356d773c65e42a` |
| Live VMs | rhvm-01=310 (nodeA, 10.10.30.19), rhvm-02=311 (nodeB, 10.10.30.17), rhvm-03=312 (nodeD, 10.10.30.18) |
| Clone template (no agent) | VMID 9001 on nodeF (`rhel10-bootc-20260606-1-tmpl`) |
| Clone template (agent baked) | VMID 9002 on nodeF (`rhel10-bootc-20260617-3-tmpl`, from `.3`) |
| HCP | org `ncdv`, project `bootc`, workspace `Komodo` |
| CephFS mount | `/mnt/cfs` on all three VMs; 6.2 TiB, cluster `59abf8dd-0b00-4909-9a15-2f1813757d3c` |

## Files Touched

- `images/templates/Containerfile.bootc.j2` (guarded entitled-install block)
- `images/build-vars.example.yml` (entitled-install vars; defaults now zsh/git only, no ceph)
- `images/op-run.publish.example` (Quay robot env mapping)
- `registry/README.md` (Quay publish target section)
- `ansible/roles/bootc_publish/{tasks,defaults,README}.md` (role filled)
- `ansible/playbooks/bootc_publish.yaml` (wired)
- `ansible/gen_terraform_inventory.py` (new — moved out of inventories/)
- `ansible/roles/bootc_build/{tasks,defaults,README}.md` (BUILD-ROLE-001 — stub → real build role)
- `ansible/playbooks/bootc_build.yaml` (BUILD-ROLE-001 — wired, loads build-vars)
- `images/op-run.build.example` (BUILD-ROLE-001 — added RHSM build-secret refs)
- `ansible/playbooks/convert_bootc_to_qcow2.yml` (PVE-TEMPLATE-001 — fixed self-referencing-var recursion)
- `images/templates/Containerfile.bootc.j2` (PUBLISH-001 — bootc_entitled_repos support + always-unregister on failure)
- `ansible/roles/bootc_ceph_mount/{tasks,defaults,README}.md` (CEPH-MOUNT-001 — new role)
- `ansible/playbooks/bootc_ceph_mount.yaml` (CEPH-MOUNT-001 — new playbook)
- `ansible/op-run.ceph.example` (CEPH-MOUNT-001 — Ceph credential env mapping)
- `feature_list.json`, `claude-progress.md`, `session-handoff.md`
- Gitignored local artifacts: `terraform/environments/dev/{main,variables,outputs,proxmox-rhvm}.tf`, `ansible.cfg`, `ansible/inventories/group_vars/bootc_targets.yml`

## Verification

- Passed: `terraform apply` (dev) → `Apply complete! 6 added` (VMs 310/311/312)
- Passed: `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.{1,2}` pushed and verified on Quay
- Passed: `.2` in-image — `qemu-guest-agent`/`cloud-init`/`sshd` enabled; no creds/entitlement leaked
- Passed: `bootc_publish` role end-to-end (re-push verified)
- Passed: `ansible-playbook --syntax-check` for all playbooks; `ansible-inventory --graph` parses
- Passed: `./init.sh` → static baseline complete
- Passed: `BUILD-ROLE-001` live end-to-end — render → `bootc_build` → `bootc_publish` → `sha256:5ed9875c…`
- Passed: `PVE-TEMPLATE-001` second template — VMID `9002` on nodeF; `qm config 9002` verified
- Passed: `PUBLISH-001` `.4` + `.5` images built and pushed; `.4` later overwritten (zsh/git only)
- Passed: `HANDOFF-001` — VMs rebuilt from 9002, IPs populated, `ansible -m ping` → SUCCESS × 3
- Passed: `CEPH-MOUNT-001` — `op run -- ansible-playbook bootc_ceph_mount.yaml` → `ok=14 changed=4 failed=0` × 3; `df -h /mnt/cfs` shows 6.2 TiB on all three VMs; `ceph-rhel-keyring.service` enabled

## Key operational knowledge: CephFS kernel mount on RHEL 10 / kernel 6.12

1. `key=<base64>` in mount options is a **kernel keyring description lookup** (not a raw value)
2. Before mounting: `python3 -c "import base64,sys; sys.stdout.buffer.write(base64.b64decode('<KEY>'))" | keyctl padd ceph "<KEY>" @s`
3. `fsname=` is renamed to `mds_namespace=` in kernel 5.4+
4. Use explicit v1 mon addresses (`host:6789,...:/`) — avoids ceph.conf msgr2 parsing
5. Boot persistence: `ceph-rhel-keyring.service` calls `/etc/ceph/load-keyring.py` before `local-fs.target`
6. `mount.ceph` is NOT included in `ceph-common` (RHCS 9 / ceph 20 for RHEL 10) — kernel client only
7. Ceph cluster admin SSH: `ssh -i /tmp/d3_ops_key d3@10.10.10.18` → `sudo ceph auth get client.rhel`

## Blockers / Risks

- Live VMs 310/311/312 SSH-reachable: rhvm-01=10.10.30.19, rhvm-02=10.10.30.17, rhvm-03=10.10.30.18
- VMs running bootc `.3` image (no `ceph-common` in image; mount uses kernel CephFS client only)
- `terraform/*.tf`, `ansible.cfg`, and the generated inventory are gitignored local artifacts
- CLEANUP: orphaned RHSM consumer `7958bb40-8d59-4770-96ec-57fc734ea9db` — remove in Red Hat Console
- Quay robot creds `op://d3HLPRV/Quay/{robot,robot_password}`; RHSM via UUID `b7gbq6kw2w3rs2nfvf4robqz2i`

## Next Session Command

```bash
cd /home/d3/Github/d3hl-rhel-bootc-orchestrator
./init.sh
# CEPH-MOUNT-001 passing; next feature is ANSIBLE-001
# bootc_targets is live, SSH-reachable, /mnt/cfs available
python3 ansible/gen_terraform_inventory.py   # regenerate inventory if IPs changed
BOOTC_SSH_PRIVATE_KEY_FILE=/tmp/d3_ops_key ansible bootc_targets -m ping
# To re-mount CephFS if VMs rebooted (keyring service should handle it; manual fallback):
# op read "op://d3HLPRV/d3_ops/private key" > /tmp/d3_ops_key && chmod 600 /tmp/d3_ops_key
# BOOTC_SSH_PRIVATE_KEY_FILE=/tmp/d3_ops_key op run --env-file ansible/op-run.ceph.example -- \
#   ansible-playbook ansible/playbooks/bootc_ceph_mount.yaml
```

## Linear sync notes

Team **d3HL**. Project **Ansible Automation Orchestrator**.

| Harness | Linear | State |
|---------|--------|-------|
| BOOTC-000 | NCD-20 | Done |
| ARCH-001 | NCD-21 | Done |
| REGISTRY-001 | NCD-22 | Done |
| IMAGE-001 | NCD-24 | Done |
| PVE-TEMPLATE-001 | NCD-29 | Done (9002 added — sync needed) |
| TF-001 | NCD-23 | Done |
| TF-002 | — | Done |
| TF-003 | — | Done (sync needed) |
| PUBLISH-001 | — | Done (sync needed) |
| BUILD-ROLE-001 | — | Done (sync needed) |
| HANDOFF-001 | — | Done (sync needed) |
| CEPH-MOUNT-001 | — | Done (sync needed) |
| ANSIBLE-001 | NCD-25 | Todo |
| CI-001 | NCD-26 | Backlog |
| E2E-001 | NCD-27 | Todo |
