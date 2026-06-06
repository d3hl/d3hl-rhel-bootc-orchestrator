# d3hl-rhel-bootc-orchestrator progress

Last updated: 2026-06-07

## Current Verified State

- New project harness exists for an Ansible-first RHEL image-mode / bootc orchestration platform.
- First deployment target: Proxmox.
- Live infrastructure actions are intentionally out of scope for the initial harness.
- `BOOTC-000` static baseline passed on 2026-06-04.
- `ARCH-001` architecture ADR accepted on 2026-06-06 (`docs/architecture/0001-ansible-first-bootc-flow.md`).
- `REGISTRY-001` registry contract accepted on 2026-06-07 (`registry/README.md`).
- `IMAGE-001` bootc image build inputs accepted on 2026-06-07 (`images/README.md`, `images/validation-checklist.md`, Ansible render role/playbook).
- Linear dual-layer workflow documented in `agent-contract-master/docs/linear-workflow.md`.
- Bootc Linear issues backfilled (NCD-20 through NCD-27); ARCH-001 synced as Done (NCD-21).

## Current Objective

Start `TF-001`: scaffold HCP Terraform Proxmox-first provisioning contract.

## Verification Evidence

- 2026-06-04 `./init.sh` passed from `/home/d3/Github/d3hl-rhel-bootc-orchestrator`.
- 2026-06-06 `./init.sh` passed after ADR 0001 and harness updates.
- 2026-06-07 `./init.sh` passed after `REGISTRY-001` contract updates.
- 2026-06-07 `images/` defines Containerfile and operator templates for user `d3` with `wheel` group, `ALL=(ALL:ALL) NOPASSWD:ALL` sudo, and SSH key reference `op://d3HLPRV/d3_ops/public key`; `ansible/playbooks/render_bootc_image_context.yml` renders build context Ansible-first; `ansible-playbook --syntax-check` and `op run` render to `/tmp/bootc-build-test` passed; `./init.sh` passed.
- `registry/README.md` documents `sudo podman`, `satellite.d3hl.site`, base image `satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab:rhel10-bootc`, username `aap`, and password reference `op://d3HL/Rhel Satelite/PAT for mcp`.
- Terraform dev environment validated successfully.
- Ansible checks skipped because `ansible-playbook` and `ansible-lint` are not installed locally.
- Git whitespace check completed.

## Blockers / Risks

- HCP Terraform, AAP, Quay/private registry, Red Hat subscription, and Proxmox credentials must remain references only.
- Live integration must remain gated behind explicit approval and recorded pre-check evidence.
- The provided registry password reference uses vault `d3HL`, while the shared secrets baseline names `d3HLPRV`; confirm the intended vault before live registry login, pull, build, or push.
- `cloud-init` and `qemu-guest-agent` package installs require RH entitlement on the build host; operator profile is baked at image build time instead.
- Linear MCP requires Cursor authentication for issue sync; repo harness remains authoritative if Linear is unavailable.

## Recommended Next Step

Choose `TF-001` as the next unfinished feature, scaffold the Proxmox-first Terraform contract under `terraform/`, then rerun `./init.sh` and sync the Linear issue when Linear access is available.
