# Registry contract

This directory documents Quay or private registry behavior for bootc images.

Initial policy:

- Use `op://d3HLPRV/...` references for credentials.
- Do not commit robot account tokens, pull secrets, Red Hat subscription secrets, or registry passwords.
- Do not create repositories or push images during static baseline checks.
- Define namespace, repository, tag, digest, and promotion rules before implementation.
