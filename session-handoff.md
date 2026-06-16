# Session handoff

Last updated: 2026-06-17

## Current Task

`HANDOFF-001` (active, **blocked**): wire the Ansible `bootc_targets` inventory
from Terraform outputs. Blocked because the live VMs report no IP (no guest
agent). This session also completed two operator-approved live milestones:
`TF-003` (live HCP apply provisioning 3 bootc VMs) and `PUBLISH-001` (RHEL 10
bootc image with `qemu-guest-agent` baked in, pushed to Quay; `bootc_publish`
role implemented).

## Artifact summary

| Field | Value |
|-------|-------|
| Quay image (via bootc_build role) | `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.3` |
| `.3` pushed digest | `sha256:5ed9875c30388e30d4d88c38e6c488e022c7b8d02c8515b9599f6ce8715071b9` |
| Quay image (with agent) | `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.2` |
| `.2` pushed digest | `sha256:57a2fa6dac8672f6ae20c18cb2edf160c048d494d5b3c695182914bd32e69aa9` |
| Quay image (no agent) | `quay.io/ncdv/rhel10-base:rhel10-bootc-20260617.1` |
| `.1` registry digest | `sha256:26fa41970ef519a3531ff18ac2cec6aeae0929840f159029fc356d773c65e42a` |
| Live VMs | rhvm-01=310 (nodeA), rhvm-02=311 (nodeB), rhvm-03=312 (nodeD) |
| Clone template | VMID 9001 on nodeF |
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
- Blocked: `terraform output ansible_inventory` → `ansible_host=null` (no agent IP); `gen_terraform_inventory.py` refuses to write

## Blockers / Risks

- Live VMs 310/311/312 report no IP: they first-booted before networking was
  fixed and lack `qemu-guest-agent`. Rebuild from the `.2` image to unblock.
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

## Next Session Command

```bash
cd /home/d3/Github/d3hl-rhel-bootc-orchestrator
./init.sh
# unblock HANDOFF-001: rebuild VMs from rhel10-bootc-20260617.2, re-apply, then:
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
| PVE-TEMPLATE-001 | NCD-29 | Done |
| TF-001 | NCD-23 | Done |
| TF-002 | — | Done |
| TF-003 | — | Done (sync needed) |
| PUBLISH-001 | — | Done (sync needed) |
| HANDOFF-001 | — | Blocked (sync needed) |
| ANSIBLE-001 | NCD-25 | Todo |
| CI-001 | NCD-26 | Backlog |
| E2E-001 | NCD-27 | Todo |
