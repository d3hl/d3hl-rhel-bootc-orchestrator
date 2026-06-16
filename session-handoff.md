# Session handoff

Last updated: 2026-06-17

## Current Task

`HANDOFF-001` (active, **blocked**): wire the Ansible `bootc_targets` inventory
from Terraform outputs. Blocked because the live VMs report no IP (no guest
agent). This session also completed operator-approved live milestones:
`TF-003` (live HCP apply provisioning 3 bootc VMs), `PUBLISH-001` (RHEL 10
bootc image with `qemu-guest-agent` baked in, pushed to Quay; `bootc_publish`
role implemented), `BUILD-ROLE-001` (build folded into the `bootc_build` role,
live-verified via `.3`), and `PVE-TEMPLATE-001` template VMID 9002 from the `.3`
image. The 9002 template (agent baked in) is the HANDOFF-001 unblock path.

## Artifact summary

| Field | Value |
|-------|-------|
| Quay image (zsh/git/ceph-common) | `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.4` |
| `.4` pushed digest | `sha256:587737ee35f60fe147db78fadf2cfc3e9152f5a74ee6afc1df50f25ac213d0e4` |
| Quay image (via bootc_build role) | `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.3` |
| `.3` pushed digest | `sha256:5ed9875c30388e30d4d88c38e6c488e022c7b8d02c8515b9599f6ce8715071b9` |
| Quay image (with agent) | `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.2` |
| `.2` pushed digest | `sha256:57a2fa6dac8672f6ae20c18cb2edf160c048d494d5b3c695182914bd32e69aa9` |
| Quay image (no agent) | `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.1` |
| `.1` registry digest | `sha256:26fa41970ef519a3531ff18ac2cec6aeae0929840f159029fc356d773c65e42a` |
| Live VMs | rhvm-01=310 (nodeA), rhvm-02=311 (nodeB), rhvm-03=312 (nodeD) |
| Clone template (no agent) | VMID 9001 on nodeF (`rhel10-bootc-20260606-1-tmpl`) |
| Clone template (agent baked) | VMID 9002 on nodeF (`rhel10-bootc-20260617-3-tmpl`, from `.3`) |
| HCP | org `ncdv`, project `bootc`, workspace `Komodo` |

## Files Touched

- `images/templates/Containerfile.bootc.j2` (guarded entitled-install block)
- `images/build-vars.example.yml` (entitled-install vars)
- `images/op-run.publish.example` (new — Quay robot env mapping)
- `registry/README.md` (Quay publish target section)
- `ansible/roles/bootc_publish/{tasks,defaults,README}.md` (role filled)
- `ansible/playbooks/bootc_publish.yaml` (wired)
- `ansible/gen_terraform_inventory.py` (new — moved out of inventories/)
- `ansible/roles/bootc_build/{tasks,defaults,README}.md` (BUILD-ROLE-001 — stub → real build role)
- `ansible/playbooks/bootc_build.yaml` (BUILD-ROLE-001 — wired, loads build-vars)
- `images/op-run.build.example` (BUILD-ROLE-001 — added RHSM build-secret refs)
- `ansible/playbooks/convert_bootc_to_qcow2.yml` (PVE-TEMPLATE-001 — fixed self-referencing-var recursion)
- `images/templates/Containerfile.bootc.j2` (PUBLISH-001 — bootc_entitled_repos support + always-unregister on failure)
- `images/build-vars.example.yml` (PUBLISH-001 — default packages now include zsh/git/ceph-common; added bootc_entitled_repos=[rhceph-9-tools-for-rhel-10-x86_64-rpms])
- `feature_list.json`, `claude-progress.md`, `session-handoff.md`
- Gitignored local artifacts: `terraform/environments/dev/{main,variables,outputs,proxmox-rhvm}.tf`, `ansible.cfg`, `ansible/inventories/group_vars/bootc_targets.yml`

## Verification

- Passed: `terraform apply` (dev) → `Apply complete! 6 added` (VMs 310/311/312)
- Passed: `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.{1,2}` pushed and verified on Quay
- Passed: `.2` in-image — `qemu-guest-agent`/`cloud-init`/`sshd` enabled; no creds/entitlement leaked
- Passed: `bootc_publish` role end-to-end (re-push verified)
- Passed: `ansible-playbook --syntax-check` for all playbooks (incl. the new `bootc_build.yaml`); `ansible-inventory --graph` parses
- Passed: `./init.sh` → static baseline complete (after `BUILD-ROLE-001` role/playbook)
- Passed: `BUILD-ROLE-001` live end-to-end — render → `bootc_build` built `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.3`, in-image agent/cloud-init/sshd enabled + no creds/entitlement leak, `bootc_publish` pushed `sha256:5ed9875c…`
- Passed: `PVE-TEMPLATE-001` second template — converted `.3` to qcow2 (sha256 `e62b7e93…`), staged to nodeF, registered VMID `9002` (`rhel10-bootc-20260617-3-tmpl`); `qm config 9002` shows `template: 1` with agent/q35/ovmf/virtio-scsi/cephVM/cloud-init
- Passed: `PUBLISH-001` `.4` build+push — `zsh`/`git`/`ceph-common` baked in (ceph via `rhceph-9-tools-for-rhel-10`); `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.4` digest `sha256:587737ee…`; in-image `ceph-common-20.1.0` (tentacle, matches cluster 20.2.1), no creds/entitlement/repo leak
- Blocked: `terraform output ansible_inventory` → `ansible_host=null` (no agent IP); `gen_terraform_inventory.py` refuses to write

## Blockers / Risks

- Live VMs 310/311/312 report no IP: they first-booted before networking was
  fixed and lack `qemu-guest-agent`. Unblock by re-cloning from template VMID
  9002 (agent baked in) — point the Terraform clone source at 9002.
- `terraform/*.tf`, `ansible.cfg`, and the generated inventory are gitignored
  local artifacts — not tracked; do not expect them in `git status`.
- Live HCP/Quay/Red Hat actions this session were operator-approved in-session
  (logged in `claude-progress.md` → Live Actions Log). Keep recording approval
  + evidence at the time of any future live action.
- The build flow is folded into the `bootc_build` role (`BUILD-ROLE-001`,
  `passing`, live-verified via `rhel10-bootc-20260617.3`); the local script
  `/tmp/build_and_push_rhel10.sh` is retired.
- Quay robot creds `op://d3HLPRV/Quay/{robot,robot_password}`; RHSM via
  `op://d3HL/<Red Hat Console: ndcv-org>` (reference by UUID — title has a `:`).
- CLEANUP: orphaned RHSM consumer `7958bb40-8d59-4770-96ec-57fc734ea9db` from
  the first `.4` attempt (failed at `dnf` before unregister). Remove it in the
  Red Hat Console. The template now always unregisters even on failure, so it
  should not recur.

## Next Session Command

```bash
cd /home/d3/Github/d3hl-rhel-bootc-orchestrator
./init.sh
# unblock HANDOFF-001: re-clone VMs from template 9002 (agent baked in), re-apply, then:
python3 ansible/gen_terraform_inventory.py
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
| HANDOFF-001 | — | Blocked (sync needed) |
| ANSIBLE-001 | NCD-25 | Todo |
| CI-001 | NCD-26 | Backlog |
| E2E-001 | NCD-27 | Todo |
