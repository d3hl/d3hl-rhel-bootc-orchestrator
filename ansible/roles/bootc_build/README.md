# bootc_build: Ansible Role

Builds the RHEL 10 bootc image from an already-rendered build context and tags
it for Quay. This is the **build** stage of the `render → build → publish`
pipeline; it does not render and does not push.

- Upstream playbook: `playbooks/bootc_build.yaml`
- Render first: `playbooks/render_bootc_image_context.yml` (role `bootc_image_render`)
- Publish after: `playbooks/bootc_publish.yaml` (role `bootc_publish`)

## What it does

1. Requires a rendered context at `bootc_build_dir` (fails if
   `Containerfile` is missing).
2. When `bootc_entitled_install` is true, requires the RHSM env vars and stages
   them as `0600` build-secret files (`no_log`), so the guarded entitled-install
   block in `images/templates/Containerfile.bootc.j2` can
   `subscription-manager register → dnf install → unregister + clean` in one
   layer with no credentials or entitlement certs left in the image.
3. Runs `podman build` under `become: true` with `--network=host`,
   `--build-arg BOOTC_BASE_IMAGE/IMAGE_TAG`, and the secret mounts, tagging
   `bootc_build_target_image`.
4. Verifies the image exists locally, removes the secret tempdir, and prints the
   matching `bootc_publish` command.

## Key variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `bootc_build_dir` | `/tmp/bootc-build` | Rendered context to build |
| `bootc_build_repository` | `quay.io/ncdv/rhel10-base` | Target repository |
| `bootc_build_tag` | `image_tag` or `rhel10-bootc-<UTC date>.1` | Build tag |
| `bootc_build_network` | `host` | WSL netavark/nft workaround |
| `bootc_entitled_install` | `true` | Bake `qemu-guest-agent` + `cloud-init` |
| `bootc_build_rhsm_user_env` / `bootc_build_rhsm_pass_env` | `RHSM_USER` / `RHSM_PASS` | Env names for the RHSM build secrets |

## Boundary

All `podman` operations run with `become: true` (the `sudo podman` boundary from
`registry/README.md`). Credentials are `op://` references resolved by `op run`
into the environment; they are never written to git, never placed on argv, and
the secret tempdir is removed after the build.

## Run

```bash
cd /home/d3/Github/d3hl-rhel-bootc-orchestrator
# 1. render
op run --env-file images/op-run.build.example -- \
  ansible-playbook ansible/playbooks/render_bootc_image_context.yml
# 2. build
op run --env-file images/op-run.build.example -- \
  ansible-playbook ansible/playbooks/bootc_build.yaml \
  -e bootc_build_tag=rhel10-bootc-YYYYMMDD.N
# 3. publish
op run --env-file images/op-run.publish.example -- \
  ansible-playbook ansible/playbooks/bootc_publish.yaml \
  -e bootc_publish_tag=rhel10-bootc-YYYYMMDD.N
```
