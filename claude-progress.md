# d3hl-rhel-bootc-orchestrator progress

Last updated: 2026-06-06

## Current Verified State

- New project harness exists for an Ansible-first RHEL image-mode / bootc orchestration platform.
- First deployment target: Proxmox.
- Live infrastructure actions are intentionally out of scope for the initial harness.
- `BOOTC-000` static baseline passed on 2026-06-04.
- `ARCH-001` architecture ADR accepted on 2026-06-06 (`docs/architecture/0001-ansible-first-bootc-flow.md`).
- Linear dual-layer workflow documented in `agent-contract-master/docs/linear-workflow.md`.
- Bootc Linear issues backfilled (NCD-20 through NCD-27); ARCH-001 synced as Done (NCD-21).

## Current Objective

Start `REGISTRY-001`: define the Quay/private registry contract.

## Verification Evidence

- 2026-06-04 `./init.sh` passed from `/home/d3/Github/d3hl-rhel-bootc-orchestrator`.
- 2026-06-06 `./init.sh` passed after ADR 0001 and harness updates.
- Terraform dev environment validated successfully.
- Ansible checks skipped because `ansible-playbook` and `ansible-lint` are not installed locally.
- Git whitespace check completed.

## Blockers / Risks

- HCP Terraform, AAP, Quay/private registry, Red Hat subscription, and Proxmox credentials must remain references only.
- Live integration must remain gated behind explicit approval and recorded pre-check evidence.
- Linear MCP requires Cursor authentication for issue sync; repo harness remains authoritative if Linear is unavailable.

## Recommended Next Step

Choose `REGISTRY-001` as the next unfinished feature, write the registry contract under `registry/`, then rerun `./init.sh` and sync the Linear issue.
