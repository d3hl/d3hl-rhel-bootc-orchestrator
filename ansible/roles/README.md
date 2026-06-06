# Ansible roles

Planned role boundaries:

- `bootc_image_render`: render `IMAGE-001` build context from `images/templates/`.
- `bootc_image_build`: prepare and validate image build inputs.
- `registry_publish`: publish and verify image metadata.
- `terraform_handoff`: prepare HCP Terraform variables or run requests.
- `proxmox_validate`: read-only target readiness and post-deploy checks.

`bootc_image_render` is implemented for `IMAGE-001`. Remaining roles are still
placeholders until later features.
