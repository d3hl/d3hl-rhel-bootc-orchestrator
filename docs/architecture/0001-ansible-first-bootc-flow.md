# ADR 0001: Ansible-first bootc orchestration and HCP Terraform boundary

Date: 2026-06-06

## Status

Accepted

## Context

The `d3hl-rhel-bootc-orchestrator` repo coordinates RHEL image-mode / bootc
deployment across image build, registry publication, HCP Terraform
provisioning, and Ansible or Ansible Automation Platform (AAP) orchestration.
Proxmox is the first deployment target.

Without explicit ownership boundaries, agents and operators may run live
actions in the wrong system (for example Terraform apply before an image is
published, or Ansible mutating build hosts). The repo harness requires static,
non-mutating work by default and evidence before any live integration.

## Decision

Adopt an **Ansible-first orchestration model** with **narrow, explicit
boundaries** for each lifecycle stage.

### Lifecycle flow

```text
build (images/) → publish (registry/) → provision (terraform/) → configure & validate (ansible/)
```

Ansible/AAP is the **top-level orchestrator** for end-to-end runs. It invokes
or hands off to other stages; it does not replace their contracts.

### System ownership

| Stage | Owner | Repo path | Responsibilities | Live actions (default) |
|-------|-------|-----------|------------------|------------------------|
| Image build | **Ansible/AAP workflow** (invoking bootc/build tooling) | `images/` | Containerfile templates, build variables, build validation checklist, artifact metadata | **Out of scope** until approved feature |
| Registry publication | **Ansible/AAP workflow** (push/promote steps) | `registry/` | Namespace/repo naming, tag conventions, promotion rules, `op://d3HLPRV/...` credential references | **Out of scope** until approved feature |
| Provisioning | **HCP Terraform** | `terraform/` | Proxmox-first VM/resource shape, workspace/module contracts, plan/apply gates | **Out of scope** until approved feature; `terraform validate` only in harness |
| Orchestration & validation | **Ansible/AAP** | `ansible/` | Inventories, playbooks, roles, workflow exports; stage sequencing; post-deploy validation | **Out of scope** until approved feature; syntax-check only in harness |

### HCP Terraform boundary

- Terraform owns **infrastructure shape** on Proxmox (VMs, disks, networks as
  defined in modules)—not image contents, registry tags, or post-boot
  configuration.
- HCP Terraform workspaces run **only** from approved features with recorded
  pre-check evidence. Static `terraform fmt` / `validate` (backend disabled
  where required) is allowed in the harness.
- Ansible passes **inputs** to Terraform stages (for example target name,
  image reference, network selection) via documented variables—not ad hoc
  CLI mutation.

### Ansible/AAP boundary

- AAP workflows **sequence** build → publish → provision → validate.
- Playbooks **do not** embed plaintext secrets; use `op://d3HLPRV/...`
  references and `op run` at execution time.
- Validation playbooks distinguish **read-only** checks (default in harness
  and E2E runbooks) from **mutating** deploy steps (explicit approval).

### Registry boundary

- `registry/` defines naming, promotion, and credential **contracts** only in
  early features.
- Quay/private registry credentials remain 1Password references; no robot
  tokens or passwords in git or Linear.

### Image build boundary

- `images/` defines bootc Containerfile templates and validation inputs—not
  live builds in the initial architecture features.
- Build hosts and subscriptions are out of scope until a dedicated feature
  records approval and verification.

## Consequences

**Easier**

- Agents know which directory and system to touch for each feature area.
- Static harness verification can run without HCP, AAP, Quay, or Proxmox
  credentials.
- Linear/human planning can map one issue per harness `id` without ambiguity.

**Harder**

- End-to-end automation requires coordinating four contracts before live
  enablement.
- Cross-stage changes need ADR updates or follow-on ADRs.

**Explicitly out of scope (until separately approved features)**

- Live bootc image build or push
- Quay repository creation or robot credential rotation
- HCP Terraform plan/apply against Proxmox
- AAP workflow import or job launch
- Red Hat subscription registration on build or target hosts

## Alternatives Considered

**Terraform-first orchestration** — Rejected. Provisioning is one stage;
Ansible/AAP already owns configuration management and is the better fit for
sequencing build/publish/validate across teams.

**Monolithic Ansible-only (no HCP Terraform)** — Rejected for Proxmox-first
target. VM lifecycle remains in Terraform modules with HCP workspace governance;
Ansible consumes Terraform outputs rather than duplicating provisioning logic.

**Separate repos per stage** — Deferred. This repo keeps boundaries by
directory and contract docs first; split only if coupling becomes painful.
