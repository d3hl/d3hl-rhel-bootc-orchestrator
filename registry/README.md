# Registry contract

This directory documents the private registry contract for RHEL image-mode /
bootc images. `REGISTRY-001` is a static contract only: it does not create
repositories, log in to the registry, build images, or push images.

## Contract inputs

| Field | Value |
|-------|-------|
| Tool | `podman` |
| Privilege boundary | All build, pull, tag, and push operations must use `sudo podman` |
| Registry | `satellite.d3hl.site` |
| Base image | `satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab:rhel10-bootc` |
| Registry username | `aap` |
| Registry password reference | `op://d3HL/Rhel Satelite/PAT for mcp` |

The password reference is a 1Password secret reference only. Do not replace it
with the secret value in git, Linear, logs, or prompts.

The shared workspace secrets baseline names vault `d3HLPRV`. The provided
runtime reference uses vault `d3HL`; confirm the intended vault name before any
live `op run`, login, build, pull, or push action.

## Repository naming

The initial image repository path is:

```text
satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab
```

The current base tag is:

```text
rhel10-bootc
```

Generated image references must keep this shape unless a later feature records
a repository migration:

```text
satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab:<tag>
```

## Tag and promotion rules

- `rhel10-bootc` is the current base/reference tag.
- Build-specific tags should include a reviewable build identifier, for example
  `rhel10-bootc-YYYYMMDD.N`.
- Promotion tags must be moved only by an approved publish/promote step, not by
  `./init.sh` or static CI.
- Terraform and Ansible should consume immutable digests once a build is
  promoted. Mutable tags are acceptable only as human-friendly aliases.

## Credential handling

Use an uncommitted environment file or execution environment that maps the
password reference to an environment variable at runtime:

```text
REGISTRY_PASSWORD=op://d3HL/Rhel Satelite/PAT for mcp
```

Candidate login command for a separately approved live step:

```bash
op run --env-file .env.registry -- sh -c 'printf "%s" "$REGISTRY_PASSWORD" | sudo podman login satellite.d3hl.site --username aap --password-stdin'
```

Do not use `op run --no-masking`. Do not store `auth.json`, pull secrets,
registry tokens, or robot/service account tokens in this repo.

## Build and push boundary

Image build and push are intentionally out of scope for `REGISTRY-001`. When a
later feature enables live image work, commands must preserve the `sudo podman`
boundary:

```bash
sudo podman pull satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab:rhel10-bootc
sudo podman build --build-arg BASE_IMAGE=satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab:rhel10-bootc --tag satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab:rhel10-bootc-YYYYMMDD.N images/
sudo podman push satellite.d3hl.site/ncdv/dev/rhel10-img/rhel_10_image_mode/d3-homelab:rhel10-bootc-YYYYMMDD.N
```

Those commands are examples for future approved live work. They must not be
added to `./init.sh` or static CI.

## Validation commands

Static validation for this contract:

```bash
./init.sh
git diff --check
```

Optional read-only checks for a later approved preflight:

```bash
command -v podman
sudo podman --version
```

Registry login, image pull, build, and push are mutating or credentialed
actions and require explicit approval plus recorded pre-check evidence.

## Rollback hints

- If a tag is generated incorrectly before push, remove only the local tag with
  `sudo podman rmi <image-ref>`.
- If a promoted tag is wrong after push, do not overwrite it silently. Record
  the digest, stop downstream Terraform/Ansible consumption, and run an
  approved registry rollback or retag procedure.
- If credentials fail, report only the `op://` reference path and the failing
  command class. Do not print or paste secret values.
