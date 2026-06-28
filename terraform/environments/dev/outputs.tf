locals {
  # First non-loopback IPv4 the guest agent reports for each VM. ipv4_addresses
  # is a list-per-interface; flatten and drop loopback to get the usable address.
  sghlrhkmd_ipv4 = {
    for name, vm in proxmox_virtual_environment_vm.sghlrhkmd :
    name => try(
      [for ip in flatten(vm.ipv4_addresses) : ip if ip != "127.0.0.1"][0],
      null
    )
  }
}

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
        for name, vm in proxmox_virtual_environment_vm.sghlrhkmd :
        name => {
          ansible_host = local.sghlrhkmd_ipv4[name]
          proxmox_node = vm.node_name
          proxmox_vmid = vm.vm_id
        }
      }
    }
  }
}
