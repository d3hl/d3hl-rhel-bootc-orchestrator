# bootc image inputs

This directory owns RHEL image-mode / bootc image templates and validation notes.

Initial policy:

- Do not build images in `./init.sh`.
- Do not push images from CI until a registry contract exists.
- Pin or otherwise document the base image strategy before live builds.
- Record image metadata needed by Terraform and Ansible before promotion.
