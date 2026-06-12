locals {
  environment = "dev"
  target      = "proxmox"
}

# Provider configuration (endpoint, credentials) is supplied via HCP Terraform
# workspace variables / variable sets at apply time, not declared in this repo.

module "bootc_vm" {
  source = "../../modules/proxmox-bootc-vm"

  proxmox_node_name = var.proxmox_node_name
  vm_name           = "bootc-${local.environment}"
  vm_id             = var.vm_id
  cpu_cores         = var.cpu_cores
  memory_mb         = var.memory_mb
  datastore_id      = var.datastore_id
  disk_size_gb      = var.disk_size_gb
}
