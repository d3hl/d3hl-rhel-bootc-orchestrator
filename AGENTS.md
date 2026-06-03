# AGENTS.md - d3hl-rhel-bootc-orchestrator

Shared workspace rules live in `agent-contract-master/AGENTS.md`. This file
adds the local harness for the RHEL image-mode / bootc orchestration repo.

Work only from this repo root for git commands, harness state, and validation.

## Project

Ansible-first orchestration platform for RHEL image-mode / bootc deployments.
The first concrete deployment target is Proxmox, but the repo keeps separate
boundaries for image build, registry, HCP Terraform, and Ansible/AAP workflows.

## Startup Workflow

Before writing code:

1. Confirm `pwd` is `/home/d3/Github/d3hl-rhel-bootc-orchestrator`.
2. Read `claude-progress.md` for Current Verified State, blockers, and next step.
3. Read `feature_list.json` and choose the highest-priority unfinished feature whose dependencies are satisfied.
4. Review recent commits with `git log --oneline -5`.
5. Run `./init.sh` and treat any failure as the first task.

`claude-progress.md` is the canonical progress log for this repo. Do not create
a separate `progress.md` unless the shared contract changes.

## Scope

- Own RHEL image-mode / bootc image pipeline design and static implementation.
- Own Quay/private registry naming, promotion, and credential-reference contracts.
- Own HCP Terraform workspace/module contracts for provisioning bootc resources.
- Own Ansible/AAP orchestration for build, publish, provision, and validation.
- Use Proxmox as the first deployment target while keeping reusable interfaces.
- Do not mutate HCP Terraform, AAP, Quay/private registry, Red Hat subscriptions, or Proxmox without explicit approval and recorded pre-check evidence.

## Verification Commands

- Baseline verification: `./init.sh`
- Terraform checks: `terraform fmt -check -recursive` and `terraform validate` with backend disabled where Terraform files exist.
- Ansible checks: `ansible-playbook --syntax-check` where playbooks exist and Ansible is installed.
- Optional lint: `ansible-lint` and `ruff` only when available locally.

`./init.sh` must remain safe for a fresh checkout: no live infrastructure
changes, no image pushes, no workflow imports, and no required 1Password
session.

## Working Rules

- One feature at a time.
- Stay in scope for the selected `feature_list.json` item.
- Prefer documented contracts and static validation before live integration.
- Do not silently change verification rules to make a feature look done.
- Record evidence before marking a feature passing.

## Definition of Done

A feature is done only when:

- Target behavior is implemented.
- Required verification ran successfully.
- Evidence includes the command, result, and date in `feature_list.json` or `claude-progress.md`.
- `./init.sh` succeeds from the repo root.
- `session-handoff.md` leaves a clean restart path if work is still in progress.

## End of Session

Before ending work:

1. Update `claude-progress.md` with Current Verified State, blockers, verification evidence, and recommended next step.
2. Update `feature_list.json` status, evidence, and next-step notes for touched features.
3. Update `session-handoff.md` with files touched, blockers, risks, and next session command.
4. Leave the repo restartable and record any dirty worktree state.

## Secrets

Follow `agent-contract-master/docs/secrets-baseline.md`.

- Use `op://d3HLPRV/...` references only.
- Never commit plaintext HCP Terraform tokens, AAP credentials, Quay robot credentials, registry tokens, Red Hat subscription secrets, SSH keys, or Proxmox credentials.
- Never paste secret values into prompts, markdown, logs, or validation output.
- If an item or field is missing, report the `op://` path only.

## Response Style

For generated config include assumptions, candidate config, validation commands,
and rollback hints.
