output "bootc_vm_id" {
  description = "Resolved Proxmox VM id for the dev bootc VM."
  value       = module.bootc_vm.vm_id
}

output "bootc_vm_name" {
  description = "Dev bootc VM name."
  value       = module.bootc_vm.vm_name
}
