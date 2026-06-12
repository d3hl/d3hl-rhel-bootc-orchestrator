variable "proxmox_node_name" {
  description = "Proxmox node that hosts the dev bootc VM."
  type        = string
  default     = "pve"
}

variable "vm_id" {
  description = "Proxmox VM id, or null to auto-assign."
  type        = number
  default     = null
}

variable "cpu_cores" {
  description = "Number of CPU cores for the dev VM."
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Dedicated memory in MiB for the dev VM."
  type        = number
  default     = 4096
}

variable "datastore_id" {
  description = "Proxmox datastore id backing the dev VM disk."
  type        = string
  default     = "local-lvm"
}

variable "disk_size_gb" {
  description = "Root disk size in GiB for the dev VM."
  type        = number
  default     = 32
}
