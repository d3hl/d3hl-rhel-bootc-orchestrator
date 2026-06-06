# bootc image inputs

This directory owns RHEL image-mode / bootc image templates and validation notes.

`IMAGE-001` is a static contract only: it does not build, push, or boot images.

## Layout

| Path | Purpose |
|------|---------|
| `templates/Containerfile.bootc.j2` | bootc OCI image definition |
| `templates/cloud-init/90-d3-user.cfg.j2` | Operator cloud-init drop-in |
| `templates/config.toml.j2` | `bootc-image-builder` disk customization |
| `templates/etc/sudoers.d/d3.j2` | Passwordless sudo for operator |
| `templates/etc/ssh/authorized_keys.j2` | Operator SSH public key target |
| `build-vars.example.yml` | Render-time variables and secret references |
| `op-run.build.example` | `op run` env mapping for Ansible render |
| `validation-checklist.md` | Static and live validation steps |

Template rendering is owned by Ansible:

- Playbook: `ansible/playbooks/render_bootc_image_context.yml`
- Role: `ansible/roles/bootc_image_render`

## Base image

Default base image from `REGISTRY-001`:

```text
satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab:rhel10-bootc
```

Override with `bootc_base_image` only through documented build variables.

## Operator profile

| Field | Value |
|-------|-------|
| Username | `d3` |
| Groups | `wheel` |
| Sudo | `ALL=(ALL:ALL) NOPASSWD:ALL` |
| SSH public key reference | `op://d3HLPRV/d3_ops/public key` |

The Containerfile bakes user `d3` at image build time. The cloud-init drop-in
remains for environments where `cloud-init` is installed later. Package installs
for `cloud-init` and `qemu-guest-agent` require RH entitlement on the build host.

## Ansible render boundary

```bash
cd /home/d3/Github/d3hl-rhel-bootc-orchestrator
op run --env-file images/op-run.build.example -- \
  ansible-playbook ansible/playbooks/render_bootc_image_context.yml \
  -e bootc_build_dir=/tmp/bootc-build
```

`sudo podman build` and push are intentionally out of scope for `./init.sh`.
When a later feature enables live image work, preserve the `sudo podman`
boundary from `registry/README.md`.

## Validation

Static validation:

```bash
./init.sh
git diff --check
```

Full checklist: `validation-checklist.md`.
