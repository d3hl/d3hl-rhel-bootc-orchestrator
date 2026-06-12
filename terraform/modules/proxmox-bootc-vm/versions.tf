terraform {
  required_version = ">= 1.6.0"

  required_providers {
    # Preferred Proxmox provider: bpg/proxmox (over telmate/proxmox).
    # Pinned pessimistically; exact approved version resolved at scaffold time: 0.109.0.
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.109"
    }
  }
}
