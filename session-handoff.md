# Session handoff

Last updated: 2026-06-07

## Current Task

`IMAGE-001` bootc image build inputs are complete. Next feature: `TF-001`.

## Files Touched

- `images/templates/Containerfile.bootc.j2`
- `images/templates/cloud-init/90-d3-user.cfg.j2`
- `images/templates/config.toml.j2`
- `images/templates/etc/sudoers.d/d3.j2`
- `images/templates/etc/ssh/authorized_keys.j2`
- `images/build-vars.example.yml`
- `images/op-run.build.example`
- `images/README.md`
- `images/validation-checklist.md`
- `ansible.cfg`
- `ansible/playbooks/render_bootc_image_context.yml`
- `ansible/roles/bootc_image_render/`
- `ansible/roles/README.md`
- `docs/secrets-references.md`
- `README.md`
- `feature_list.json`
- `claude-progress.md`
- `session-handoff.md`

## Verification

- Passed: `./init.sh` from `/home/d3/Github/d3hl-rhel-bootc-orchestrator` (2026-06-07)
- Passed: `images/` templates and validation checklist for operator user `d3`
- Passed: Ansible-first render path via `ansible/playbooks/render_bootc_image_context.yml`
- No live Ansible render with `op run`, image build, push, or first-boot validation was run in harness verification

## Blockers / Risks

- No live HCP Terraform, AAP, Quay/private registry, image push, Red Hat subscription, or Proxmox mutation is approved.
- SSH public key must resolve only during Ansible render via `op run` and `op://d3HLPRV/d3_ops/public key`.
- Registry password reference still uses vault `d3HL` in `registry/README.md`; shared baseline names `d3HLPRV`.
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
| IMAGE-001 | NCD-23 (Backlog; repo state passing, Linear sync pending) |

See `agent-contract-master/docs/linear-workflow.md` for full mapping.
