# Terraform Environment — d3HL RHEL Bootc Orchestrator

## Workspace/Repository Contract

- **HCP Terraform:** Remote state and remote execution only, via `terraform { cloud { ... } }` block. No backend block.
- **Organization/Workspace:** Set `organization` and `workspace` in `main.tf` to approved values before production use. The HCP **project** is assigned to the workspace through the Terraform Cloud/TFE UI or API – it is **not** configured in the repo.
    - Organization: `REPLACE_ME_ORG`
    - Workspace: `Komodo`
- **No secrets or credentials stored in repository:** _All_ secrets are referenced as `op://d3HLPRV/...` secure paths only. _Never_ write, output, or expand secret values in the repo.

## Variables and Inputs

- Provider and deploy credentials (Proxmox API tokens, cloud-init SSH keys) are provided either:
  - _as Terraform cloud/HCP workspace environment variables,_ or
  - _in a variable set referenced by workspace_.
- Populate all sensitive values with `op://d3HLPRV/...` references in variable setup UI only.

## Layout

```
terraform/
  environments/
    dev/
      main.tf                  # Terraform remote exec and provider pinning
      variables.tf             # All variable declarations (incl. secrets as references)
      proxmox-rhvm.tf          # Proxmox VM resources and cloud-init
      cloudinit-user-data.yaml.tftpl # User-data injected for "aap" user
  README.md
```

## File Handling / Safety

- `.terraformignore` prevents leaking local state, generated files, and secrets-adjacent artifacts to remote.
- Only `*.tf`, `*.tftpl`, and HC standardized handoff files are committed.
- Never commit local credentials, tokens, or download artifacts from Proxmox/Cloud without handler review.

## Output and Integration

- VM details (hostname, node, VMID, IP) are designed as Terraform resources, available for output or lookup by later Ansible or pipeline jobs.
- No OS-level configuration or registration occurs here—this contract is provision-only. Downstream configuration (e.g. with Ansible) should consume attributes from the deployed VMs or their outputs.

## Validation

- All `.tf` files **must pass**:
    - `terraform fmt`
    - `terraform validate -no-color -backend=false`
- No secret or credential information should be printed in plan or logs.

## Support & Next Steps

- To update secrets or endpoints, change workspace variable values—_never in the repo_.
- All post-provisioning, registration, and configuration is deferred to Ansible and future playbooks.
