output "rhvm_vms" {
  description = "Provisioned bootc VMs: name => { node, id }."
  value = {
    for name, vm in proxmox_virtual_environment_vm.rhvm :
    name => {
      node = vm.node_name
      id   = vm.vm_id
    }
  }
}

output "rhvm_names" {
  description = "Names of the provisioned bootc VMs."
  value       = keys(proxmox_virtual_environment_vm.rhvm)
}
