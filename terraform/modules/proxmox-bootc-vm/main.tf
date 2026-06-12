# Proxmox-first bootc VM resource shape, expressed with the bpg/proxmox provider.
# Plan-only contract: no `provider` configuration block, endpoints, or credentials
# live here. Provider auth is supplied via Terraform variables and HCP Terraform
# workspace variable sets at apply time, never in repo `.tf` files.
resource "proxmox_virtual_environment_vm" "bootc" {
  node_name   = var.proxmox_node_name
  name        = var.vm_name
  vm_id       = var.vm_id
  description = var.vm_description
  tags        = var.tags

  agent {
    enabled = true
  }

  cpu {
    cores   = var.cpu_cores
    sockets = var.cpu_sockets
    type    = "host"
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    datastore_id = var.datastore_id
    interface    = var.disk_interface
    size         = var.disk_size_gb
  }

  # network_device {...} is intentionally omitted in this skeleton and added when
  # networking is wired (var.network_bridge / var.network_vlan_id drive it).

  lifecycle {
    # Guard against accidental replacement once a real VM exists.
    ignore_changes = [vm_id]
  }
}
