# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Ansible-first orchestration harness for building RHEL 10 bootc OCI images, publishing to a private registry (`satellite.d3hl.site`), and provisioning Proxmox VM templates via Ansible. HCP Terraform scaffolding is static/validation-only until explicitly unlocked per feature.

**Read `AGENTS.md` before any session.** It defines scope boundaries, the startup workflow, definition of done, and end-of-session checklist that must be followed.

## Startup

```bash
./init.sh                # must pass before any work begins
cat session-handoff.md   # current task, blockers, next command
cat claude-progress.md   # verified feature state and evidence log
```

`./init.sh` runs: required-file checks, JSON lint (`feature_list.json`), Terraform fmt/validate, Ansible syntax-check for every playbook, and `git diff --check`. It is also what CI runs (`.github/workflows/static.yml`).

## Key commands

**Ansible syntax-check (individual playbook):**
```bash
ansible-playbook --syntax-check ansible/playbooks/<name>.yml
```

**Render image build context (static, no image build):**
```bash
op run --env-file images/op-run.build.example -- \
  ansible-playbook ansible/playbooks/render_bootc_image_context.yml \
  -e bootc_build_dir=/tmp/bootc-build
```

**Proxmox preflight (read-only):**
```bash
op run --env-file ansible/op-run.proxmox.example -- \
  ansible-playbook -i ansible/inventories/proxmox-first.yml \
  ansible/playbooks/preflight_proxmox_template.yml \
  -e pve_template_node=nodeF
```

**Terraform static validation:**
```bash
terraform fmt -check -recursive terraform/
cd terraform/environments/dev && terraform init -backend=false && terraform validate
```

## Architecture

The flow is linear and Ansible-owned end-to-end:

```
images/ templates → bootc_image_render role → rendered Containerfile/config
→ bootc-image-builder (Codex, live, separate) → OCI image → qcow2
→ bootc_proxmox_template role → Proxmox VM template (VMID 9001, nodeF)
→ HCP Terraform (TF-001, static scaffold) → Proxmox VMs
→ AAP workflow (ANSIBLE-001, static scaffold) → lifecycle orchestration
```

**Ownership boundaries** (from ADR `docs/architecture/0001-ansible-first-bootc-flow.md`):
- Image build: `images/` + `bootc_image_render` role (Ansible renders inputs; Codex runs podman build)
- Registry: `satellite.d3hl.site` — contract in `registry/README.md`, no live push in harness
- Terraform: static validation only; no HCP state or apply
- Ansible/AAP: top-level sequencer; playbooks in `ansible/playbooks/`, roles in `ansible/roles/`

## Scope rules

- **Do not** run live HCP Terraform apply, import AAP workflows, push images, or mutate Proxmox infrastructure without an explicit approved feature gate.
- **All secrets** come from 1Password (`op run`) using `d3HLPRV` vault only — no plaintext credentials anywhere.
- Every feature in `feature_list.json` requires recorded verification evidence before marking PASSING.
- The `bootc_proxmox_template` role has guard checks (VMID exists, name match, `pve_template_allow_replace_any` approval gate) — never bypass them.

## Feature tracking

`feature_list.json` is the source of truth. Current order: BOOTC-000 → ARCH-001 → REGISTRY-001 → IMAGE-001 → PVE-TEMPLATE-001 → **TF-001 (next)** → ANSIBLE-001 → CI-001 → E2E-001.

Update `claude-progress.md` and `session-handoff.md` at end of every session.

## Secrets

All credentials are `op://d3HLPRV/...` references. Example files: `ansible/op-run.proxmox.example`, `images/op-run.build.example`, `images/build-vars.example.yml`. See `docs/secrets-references.md` for the full reference list.
