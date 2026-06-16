# bootc_publish: Ansible Role

Pushes a locally built bootc image to the Quay registry
(`quay.io/ncdv/rhel10-base` by default) so the publish step is reproducible.

## What it does

1. Asserts the robot credentials are present in the environment
   (`QUAY_ROBOT` / `QUAY_ROBOT_PASSWORD`).
2. Logs in to `quay.io` with `sudo podman login --password-stdin` using a
   throwaway authfile (no `auth.json` left behind).
3. Tags the source image as the target ref when they differ.
4. Pushes the image and records the digest via `podman push --digestfile`.

## Run

```bash
op run --env-file images/op-run.publish.example -- \
  ansible-playbook ansible/playbooks/bootc_publish.yaml \
  -e bootc_publish_tag=rhel10-bootc-YYYYMMDD.N
```

## Variables

See `defaults/main.yml`. Common overrides:

- `bootc_publish_tag` — build tag (convention `rhel10-bootc-YYYYMMDD.N`).
- `bootc_publish_source_image` — local image to push if it differs from the target.
- `bootc_publish_repository` — defaults to `quay.io/ncdv/rhel10-base`.

Credentials are 1Password references resolved by `op run`; they are never
stored in git, logs, or `auth.json`. All podman calls use the `sudo podman`
boundary from `registry/README.md`.

- Upstream playbook: `playbooks/bootc_publish.yaml`
