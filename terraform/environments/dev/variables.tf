# --- Proxmox provider and environment ---
variable "proxmox_api_url" {
  description = "Proxmox API endpoint URL"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token (reference as op://d3HLPRV/PROXMOX/API_TOKEN)"
  type        = string
  sensitive   = true
  default     = "op://d3HLPRV/proxmox_env/PROXMOX_API_TOKEN"
}

# --- Node logic and mapping ---
variable "rhvm_hosts" {
  description = "Mapping of VM names to Proxmox nodes"
  type        = map(string)
  default = {
    rhvm-01 = "nodeA"
    rhvm-02 = "nodeB"
    rhvm-03 = "nodeD"
  }
}

variable "rhvm_list" {
  description = "List of VM hostnames to provision"
  type        = list(string)
  default     = ["rhvm-01", "rhvm-02", "rhvm-03"]
}

# --- VM Spec vars ---
variable "rhvm_vcpu" {
  description = "Number of vCPUs for each VM"
  type        = number
  default     = 4
}

variable "rhvm_memory" {
  description = "Memory (in MB) for each VM"
  type        = number
  default     = 16384
}

variable "rhvm_disk_gb" {
  description = "Disk size (GB) for each VM"
  type        = number
  default     = 100
}

variable "rhvm_template_vmid" {
  description = "Proxmox template VMID"
  type        = number
  default     = 9001
}

variable "rhvm_network_bridge" {
  description = "Proxmox network bridge for VM NIC"
  type        = string
  default     = "vsvc"
}

# --- Cloud-init and access vars ---
variable "ci_username" {
  description = "Username for cloud-init (should be 'aap')"
  type        = string
  default     = "aap"
}

variable "ci_ssh_public_key" {
  description = "SSH public key for cloud-init user"
  type        = string
  sensitive   = true
  default     = "op://d3HLPRV/d3_ops/public key"
  # Set via HCP variable referencing "op://d3HLPRV/d3_ops/public key"
}

# --- Storage targets ---
variable "rhvm_storage" {
  description = "Proxmox datastore for VM disks (shared, supports images)."
  type        = string
  default     = "cephVM"
}

variable "rhvm_snippet_datastore" {
  description = <<-EOT
    Proxmox datastore for cloud-init snippets. Must have the 'snippets' content
    type enabled and be reachable on every target node (nodeA/nodeB/nodeD).
    cephVM advertises only rootdir,images, so it cannot hold snippets.
  EOT
  type        = string
  default     = "cFS"
}
