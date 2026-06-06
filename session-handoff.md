# Session handoff

Last updated: 2026-06-07

## Current Task

`REGISTRY-001` registry contract is complete. Next feature: `IMAGE-001`.

## Files Touched

- `registry/README.md`
- `feature_list.json`
- `claude-progress.md`
- `session-handoff.md`

## Verification

- Passed: `./init.sh` from `/home/d3/Github/d3hl-rhel-bootc-orchestrator` (2026-06-06)
- Passed: ADR 0001 names owners for image build, registry, HCP Terraform, and Ansible/AAP
- Passed: Linear bootc issues NCD-20–NCD-27 created; ARCH-001 synced as Done (NCD-21)
- Passed: `registry/README.md` defines the `satellite.d3hl.site` registry contract, `sudo podman` boundary, base image, `aap` username, 1Password password reference, tag/promotion rules, validation commands, and rollback hints
- Passed: `./init.sh` from `/home/d3/Github/d3hl-rhel-bootc-orchestrator` (2026-06-07)

## Blockers / Risks

- No live HCP Terraform, AAP, Quay/private registry, image push, Red Hat subscription, or Proxmox mutation is approved.
- No live registry login, image pull, image build, or image push was run for `REGISTRY-001`.
- The provided registry password reference uses vault `d3HL`, while the shared secrets baseline names `d3HLPRV`; confirm vault name before live registry actions.
- Keep the existing `/home/d3/Github/d3hl-infra-bootc-pipeline` untouched.

## Next Session Command

```bash
cd /home/d3/Github/d3hl-rhel-bootc-orchestrator
sed -n '1,220p' claude-progress.md
cat feature_list.json
./init.sh
```

## Linear sync notes

Team **d3HL**. Project **bootc-orchestrator**: https://linear.app/ncdv/project/bootc-orchestrator-39ad2dfde76c

| Harness | Linear |
|---------|--------|
| BOOTC-000 | NCD-20 (Done) |
| ARCH-001 | NCD-21 (Done) |
| REGISTRY-001 | NCD-22 (Backlog; repo state passing, Linear sync pending) |
| IMAGE-001 | NCD-23 (Backlog) |

See `agent-contract-master/docs/linear-workflow.md` for full mapping.
