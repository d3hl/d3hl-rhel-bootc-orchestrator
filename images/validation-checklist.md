# bootc image validation checklist

`IMAGE-001` is a static contract only. It does not build, push, or boot images.

## Assumptions

- Base image matches `registry/README.md`: `satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab:rhel10-bootc`.
- Operator profile targets user `d3` in group `wheel` with `ALL=(ALL:ALL) NOPASSWD:ALL`.
- SSH public key resolves from `op://d3HLPRV/d3_ops/public key` at Ansible render time only.

## Static validation

```bash
cd /home/d3/Github/d3hl-rhel-bootc-orchestrator
./init.sh
git diff --check
test -f images/templates/Containerfile.bootc.j2
test -f images/templates/cloud-init/90-d3-user.cfg.j2
test -f images/build-vars.example.yml
test -f images/validation-checklist.md
test -f ansible/playbooks/render_bootc_image_context.yml
```

Expected result: required templates, Ansible render playbook, and checklist exist.

## Ansible render preflight (approved live build only)

Render the build context with Ansible. Do not commit rendered output.

```bash
cd /home/d3/Github/d3hl-rhel-bootc-orchestrator
op run --env-file images/op-run.build.example -- \
  ansible-playbook ansible/playbooks/render_bootc_image_context.yml \
  -e bootc_build_dir=/tmp/bootc-build
```

Candidate render layout:

```text
/tmp/bootc-build/
  Containerfile
  config.toml
  etc/cloud/cloud.cfg.d/90-d3-user.cfg
  etc/sudoers.d/d3
  etc/ssh/authorized_keys
```

## Build preflight (approved live build only)

Requires registry login per `registry/README.md` and `sudo podman`.

```bash
sudo podman pull satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab:rhel10-bootc
sudo podman build \
  --network=host \
  --build-arg BOOTC_BASE_IMAGE=satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab:rhel10-bootc \
  --tag satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab:rhel10-bootc-YYYYMMDD.N \
  /tmp/bootc-build
```

## First-boot validation (approved live boot only)

After `bootc-image-builder` conversion and Proxmox provisioning:

```bash
cloud-init status --wait
id d3
groups d3
sudo -l -U d3
grep -F 'NOPASSWD:ALL' /etc/sudoers /etc/sudoers.d/* 2>/dev/null
test -f /home/d3/.ssh/authorized_keys
ssh -o BatchMode=yes d3@<vm-ip> true
```

## Rollback hints

- If render fails, report only `op://d3HLPRV/d3_ops/public key`; do not paste key values.
- If the rendered build context is wrong, delete `/tmp/bootc-build` and re-run the Ansible playbook.
- If a bad image was pushed, record the digest and follow `registry/README.md` rollback guidance.
