# d3hl-rhel-bootc-orchestrator

Ansible-first orchestration platform for deploying RHEL image-mode / bootc
resources. The first concrete target is Proxmox, with clean boundaries between
image build, registry publication, HCP Terraform provisioning, and Ansible or
Ansible Automation Platform orchestration.

This repo starts as a safe static harness. It does not run live HCP Terraform,
import AAP workflows, push images, change Quay/private registry settings, or
touch Proxmox infrastructure until a feature explicitly adds those actions and
records approval requirements.

## Contents

| Path | Purpose |
| ---- | ------- |
| `AGENTS.md` | Agent startup, scope, verification, and safety rules |
| `feature_list.json` | Feature backlog, status, verification, and evidence |
| `claude-progress.md` | Current verified state and session log |
| `init.sh` | Static baseline verification |
| `session-handoff.md` | Restart notes and unresolved risks |
| `ansible/` | Inventories, playbooks, roles, and AAP workflow exports |
| `terraform/` | HCP Terraform workspace contracts, modules, and environments |
| `images/` | bootc image templates and validation notes |
| `registry/` | Quay/private registry naming and credential reference contract |
| `docs/` | Architecture decisions, runbooks, secrets, and verification docs |

## Startup

```bash
pwd
sed -n '1,220p' claude-progress.md
cat feature_list.json
git log --oneline -5
./init.sh
```

The first unfinished feature is `BOOTC-000`: establish the repo harness and
static baseline. Do not implement live infrastructure while completing that
feature.
