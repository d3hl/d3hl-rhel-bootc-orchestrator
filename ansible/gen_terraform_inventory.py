#!/usr/bin/env python3
"""Generate the bootc_targets Ansible inventory from HCP Terraform outputs.

Per ADR 0001, Ansible *consumes* Terraform outputs for host facts and does not
re-provision. This reads `terraform output -json ansible_inventory` from the dev
environment and writes a static inventory file that the inventory directory
picks up alongside proxmox-first.yml. Connection identity (user, ssh key, become)
lives in group_vars/bootc_targets.yml on the Ansible side, not here.

Usage:
    python3 ansible/inventories/gen_terraform_inventory.py
"""

from __future__ import annotations

import json
import pathlib
import subprocess
import sys

REPO = pathlib.Path(__file__).resolve().parents[1]
TF_DIR = REPO / "terraform" / "environments" / "dev"
OUT = REPO / "ansible" / "inventories" / "terraform.generated.yml"


def main() -> int:
    try:
        raw = subprocess.check_output(
            ["terraform", f"-chdir={TF_DIR}", "output", "-json", "ansible_inventory"],
            text=True,
        )
    except (subprocess.CalledProcessError, FileNotFoundError) as exc:
        sys.exit(f"failed to read terraform output: {exc}")

    data = json.loads(raw)
    hosts = data.get("bootc_targets", {}).get("hosts", {})
    if not hosts:
        sys.exit("no bootc_targets hosts in terraform output — has apply run?")

    missing = sorted(h for h, v in hosts.items() if not v.get("ansible_host"))
    if missing:
        sys.exit(
            f"refusing to write inventory: no IP for {missing}. "
            "Is the guest agent reporting? Re-run terraform apply."
        )

    inventory = {"all": {"children": {"bootc_targets": {"hosts": hosts}}}}
    body = (
        "# GENERATED from `terraform output -json ansible_inventory`.\n"
        "# Do not edit by hand — re-run gen_terraform_inventory.py instead.\n"
        + json.dumps(inventory, indent=2, sort_keys=True)
        + "\n"
    )
    OUT.write_text(body)
    print(f"wrote {OUT.relative_to(REPO)} with {len(hosts)} host(s): {', '.join(sorted(hosts))}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
