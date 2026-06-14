#!/usr/bin/env bash
# Probe bootc repo structure for Komodo workspace planning
set -euo pipefail

echo "=== Repo root ==="
ls -la /home/d3/Github/d3hl-rhel-bootc-orchestrator/

echo ""
echo "=== terraform/ tree ==="
find /home/d3/Github/d3hl-rhel-bootc-orchestrator/terraform -type f | sort

echo ""
echo "=== module variables.tf ==="
cat /home/d3/Github/d3hl-rhel-bootc-orchestrator/terraform/modules/proxmox-bootc-vm/variables.tf 2>/dev/null || echo "NOT FOUND"

echo ""
echo "=== module outputs.tf ==="
cat /home/d3/Github/d3hl-rhel-bootc-orchestrator/terraform/modules/proxmox-bootc-vm/outputs.tf 2>/dev/null || echo "NOT FOUND"

echo ""
echo "=== module main.tf ==="
cat /home/d3/Github/d3hl-rhel-bootc-orchestrator/terraform/modules/proxmox-bootc-vm/main.tf 2>/dev/null || echo "NOT FOUND"

echo ""
echo "=== dev environment main.tf ==="
cat /home/d3/Github/d3hl-rhel-bootc-orchestrator/terraform/environments/dev/main.tf 2>/dev/null || echo "NOT FOUND"

echo ""
echo "=== dev environment variables.tf ==="
cat /home/d3/Github/d3hl-rhel-bootc-orchestrator/terraform/environments/dev/variables.tf 2>/dev/null || echo "NOT FOUND"

echo ""
echo "=== dev environment terraform.tfvars ==="
cat /home/d3/Github/d3hl-rhel-bootc-orchestrator/terraform/environments/dev/terraform.tfvars 2>/dev/null || echo "NOT FOUND"

echo ""
echo "=== dev environment files/ ==="
find /home/d3/Github/d3hl-rhel-bootc-orchestrator/terraform/environments/dev/files -type f 2>/dev/null || echo "NOT FOUND"

echo ""
echo "=== feature_list.json ==="
cat /home/d3/Github/d3hl-rhel-bootc-orchestrator/feature_list.json 2>/dev/null || echo "NOT FOUND"

echo ""
echo "=== init.sh ==="
cat /home/d3/Github/d3hl-rhel-bootc-orchestrator/init.sh 2>/dev/null || echo "NOT FOUND"

echo ""
echo "=== .terraformignore (root) ==="
cat /home/d3/Github/d3hl-rhel-bootc-orchestrator/.terraformignore 2>/dev/null || echo "NOT FOUND"