output "vm_id" {
  description = "Resolved Proxmox VM id."
  value       = proxmox_virtual_environment_vm.bootc.vm_id
}

output "vm_name" {
  description = "VM name."
  value       = proxmox_virtual_environment_vm.bootc.name
}

output "node_name" {
  description = "Proxmox node hosting the VM."
  value       = proxmox_virtual_environment_vm.bootc.node_name
}
