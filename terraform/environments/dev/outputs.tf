locals {
  # First non-loopback IPv4 the guest agent reports for each VM. ipv4_addresses
  # is a list-per-interface; flatten and drop loopback to get the usable address.
  rhvm_ipv4 = {
    for name, vm in proxmox_virtual_environment_vm.rhvm :
    name => try(
      [for ip in flatten(vm.ipv4_addresses) : ip if ip != "127.0.0.1"][0],
      null
    )
  }
  sghlrhkmd_ipv4 = {
    for name, vm in proxmox_virtual_environment_vm.sghlrhkmd :
    name => try(
      [for ip in flatten(vm.ipv4_addresses) : ip if ip != "127.0.0.1"][0],
      null
    )
  }
}

output "rhvm_vms" {
  description = "Provisioned bootc VMs: name => { node, id, ipv4 }."
  value = {
    for name, vm in proxmox_virtual_environment_vm.rhvm :
    name => {
      node = vm.node_name
      id   = vm.vm_id
      ipv4 = local.rhvm_ipv4[name]
    }
  }
}

output "rhvm_names" {
  description = "Names of the provisioned bootc VMs."
  value       = keys(proxmox_virtual_environment_vm.rhvm)
}

# Ready-to-consume Ansible inventory for the bootc_targets group. Render to a
# file with the generator under ansible/inventories/ (terraform output -json
# ansible_inventory). Ansible consumes Terraform outputs; it does not
# re-provision.
output "sghlrhkmd_vms" {
  description = "Provisioned sg-hl-rhkmd VMs: name => { node, id, ipv4 }."
  value = {
    for name, vm in proxmox_virtual_environment_vm.sghlrhkmd :
    name => {
      node = vm.node_name
      id   = vm.vm_id
      ipv4 = local.sghlrhkmd_ipv4[name]
    }
  }
}

output "ansible_inventory" {
  description = "bootc_targets inventory hosts, keyed by VM name, for the Ansible handoff."
  value = {
    bootc_targets = {
      hosts = {
        for name, vm in proxmox_virtual_environment_vm.rhvm :
        name => {
          ansible_host = local.rhvm_ipv4[name]
          proxmox_node = vm.node_name
          proxmox_vmid = vm.vm_id
        }
      }
    }
  }
}
