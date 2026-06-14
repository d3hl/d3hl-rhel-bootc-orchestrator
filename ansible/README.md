# d3hl-rhel-bootc-orchestrator — Ansible Orchestration Skeleton

**Scope:**  
This directory scaffolds the Ansible automation shape for d3HL bootc build/publish/provision/validate orchestration, as well as initial AAP (Ansible Automation Platform) workflow handoff.

**Contents:**
- `inventory/` — Static or dynamic inventories (currently stub)
- `playbooks/` — One playbook per workflow phase (build, publish, provision, validate)
- `roles/` — One role per playbook step; each directory persists with a `README.md`
- AAP workflow export as a baseline YAML handoff structure (`../aap_exports/`)

**Future Integration Points:**
- No dynamic inventory, hostnames, or secrets are included here; refer to HCP Terraform workspace outputs and 1Password secrets (op://d3HLPRV/...) when live infrastructure is linked in future features.
- Playbooks reference stub roles; see ADR and architecture docs for full workflow intent.
- AAP workflow export (`aap_exports/bootc_orchestration_workflow.yaml`) is non-executable and should be overwritten by real AAP job workflow exports upon AAP integration.

**This scaffold does not execute, deploy, or configure any infrastructure.**
