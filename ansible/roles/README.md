# Ansible roles

Planned role boundaries:

- `bootc_image_build`: prepare and validate image build inputs.
- `registry_publish`: publish and verify image metadata.
- `terraform_handoff`: prepare HCP Terraform variables or run requests.
- `proxmox_validate`: read-only target readiness and post-deploy checks.

Roles are intentionally not implemented in the initial harness.
