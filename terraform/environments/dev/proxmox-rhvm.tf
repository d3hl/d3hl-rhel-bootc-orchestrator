locals {
  rhvm_data = {
    for vm in var.rhvm_list : vm => {
      node   = var.rhvm_hosts[vm]
      name   = vm
      ci_tpl = "${vm}-user-data.yaml"
    }
  }
}

# Generate cloud-init user-data file for each VM
resource "proxmox_virtual_environment_file" "cloudinit_user_data" {
  for_each = local.rhvm_data

  content_type = "snippets"
  node_name    = each.value.node
  datastore_id = var.rhvm_snippet_datastore

  source_raw {
    data = templatefile("${path.module}/cloudinit-user-data.yaml.tftpl", {
      username       = var.ci_username
      ssh_public_key = var.ci_ssh_public_key
    })
    file_name = each.value.ci_tpl
  }
}

resource "proxmox_virtual_environment_vm" "rhvm" {
  for_each = local.rhvm_data

  node_name   = each.value.node
  name        = each.value.name
  vm_id       = var.rhvm_vmids[each.key]
  description = "HCP TF provisioned rhvm VM ${each.value.name}"
  tags        = ["bootc"]

  # Clone from template (VMID auto-allocated by Proxmox). node_name names the
  # source node the template lives on, enabling cross-node clones to other nodes.
  clone {
    vm_id     = var.rhvm_template_vmid
    node_name = var.rhvm_template_node
    full      = true
  }

  cpu {
    cores = var.rhvm_vcpu
    type = "host"
  }

  memory {
    dedicated = var.rhvm_memory
  }

  disk {
    datastore_id = var.rhvm_storage
    interface    = "scsi0"
    size         = var.rhvm_disk_gb
  }

  network_device {
    bridge = var.rhvm_network_bridge
    model  = "virtio"
  }

  # Agent enabled now that VM networking is sorted — the guest agent publishes
  # the VM's IP, which the Ansible handoff consumes via the rhvm_vms output.
  agent {
    enabled = true
    timeout = "10m"
  }

  # Attach cloud-init user-data
  initialization {
    user_data_file_id = proxmox_virtual_environment_file.cloudinit_user_data[each.key].id
  }

  # Order: VM creation waits for cloud-init user-data to be present
  depends_on = [
    proxmox_virtual_environment_file.cloudinit_user_data
  ]
}
