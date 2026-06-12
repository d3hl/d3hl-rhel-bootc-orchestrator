variable "proxmox_node_name" {
  description = "Proxmox node that hosts the bootc VM."
  type        = string

  validation {
    condition     = length(trimspace(var.proxmox_node_name)) > 0
    error_message = "proxmox_node_name must not be empty."
  }
}

variable "vm_name" {
  description = "VM name as shown in Proxmox."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.vm_name))
    error_message = "vm_name must be lowercase alphanumeric with hyphens."
  }
}

variable "vm_id" {
  description = "Proxmox VM id. Use null to let Proxmox assign the next free id."
  type        = number
  default     = null

  validation {
    condition     = var.vm_id == null || var.vm_id >= 100
    error_message = "vm_id must be null or an integer >= 100."
  }
}

variable "vm_description" {
  description = "Human-readable description for the VM."
  type        = string
  default     = "RHEL bootc VM (managed by Terraform, bpg/proxmox)."
}

variable "tags" {
  description = "Proxmox tags applied to the VM."
  type        = list(string)
  default     = ["bootc", "terraform"]
}

variable "cpu_cores" {
  description = "Number of CPU cores."
  type        = number
  default     = 2

  validation {
    condition     = var.cpu_cores >= 1
    error_message = "cpu_cores must be >= 1."
  }
}

variable "cpu_sockets" {
  description = "Number of CPU sockets."
  type        = number
  default     = 1

  validation {
    condition     = var.cpu_sockets >= 1
    error_message = "cpu_sockets must be >= 1."
  }
}

variable "memory_mb" {
  description = "Dedicated memory in MiB."
  type        = number
  default     = 4096

  validation {
    condition     = var.memory_mb >= 512
    error_message = "memory_mb must be >= 512."
  }
}

variable "datastore_id" {
  description = "Proxmox datastore id that backs the VM disk."
  type        = string
  default     = "local-lvm"
}

variable "disk_interface" {
  description = "Disk interface (for example scsi0, virtio0)."
  type        = string
  default     = "scsi0"
}

variable "disk_size_gb" {
  description = "Root disk size in GiB."
  type        = number
  default     = 32

  validation {
    condition     = var.disk_size_gb >= 8
    error_message = "disk_size_gb must be >= 8."
  }
}

# Network is provisioned via a bpg/proxmox `network_device` block once networking
# is wired (see README). These inputs describe that future contract without
# forcing live provider configuration in this skeleton feature.
variable "network_bridge" {
  description = "Proxmox bridge for the primary network interface (future use)."
  type        = string
  default     = "vmbr0"
}

variable "network_vlan_id" {
  description = "VLAN id for the primary network interface, or null for untagged (future use)."
  type        = number
  default     = null
}
