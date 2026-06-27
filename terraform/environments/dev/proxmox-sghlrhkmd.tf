locals {
  sghlrhkmd_data = {
    for vm in var.sghlrhkmd_list : vm => {
      node   = var.sghlrhkmd_hosts[vm]
      name   = vm
      ci_tpl = "${vm}-user-data.yaml"
    }
  }
}

# Generate cloud-init user-data file for each sg-hl-rhkmd VM.
# Reuses the same cloudinit-user-data.yaml.tftpl as the rhvm group; creates
# user d3 with the key from var.sg_ci_ssh_public_key (1Password item 5jenjts2ywrnvrasi26xjacdne).
resource "proxmox_virtual_environment_file" "cloudinit_sghlrhkmd" {
  for_each = local.sghlrhkmd_data

  content_type = "snippets"
  node_name    = each.value.node
  datastore_id = var.rhvm_snippet_datastore

  source_raw {
    data = templatefile("${path.module}/cloudinit-user-data.yaml.tftpl", {
      username       = "d3"
      ssh_public_key = var.sg_ci_ssh_public_key
    })
    file_name = each.value.ci_tpl
  }
}

resource "proxmox_virtual_environment_vm" "sghlrhkmd" {
  for_each = local.sghlrhkmd_data

  node_name   = each.value.node
  name        = each.value.name
  vm_id       = var.sghlrhkmd_vmids[each.key]
  description = "HCP TF provisioned sg-hl-rhkmd VM ${each.value.name}"
  tags        = ["bootc"]

  clone {
    vm_id     = var.sghlrhkmd_template_vmid
    node_name = var.sghlrhkmd_template_node
    full      = true
  }

  cpu {
    cores = var.rhvm_vcpu
    type  = "host"
  }

  memory {
    dedicated = var.rhvm_memory
  }

  disk {
    datastore_id = var.rhvm_storage
    interface    = "scsi0"
    size         = var.rhvm_disk_gb
  }

  disk {
    datastore_id = var.rhvm_storage
    interface    = "scsi1"
    size         = 100
  }

  network_device {
    bridge = var.rhvm_network_bridge
    model  = "virtio"
  }

  agent {
    enabled = true
    timeout = "10m"
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.cloudinit_sghlrhkmd[each.key].id
  }

  depends_on = [
    proxmox_virtual_environment_file.cloudinit_sghlrhkmd
  ]
}
