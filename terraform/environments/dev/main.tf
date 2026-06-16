terraform {
  cloud {
    organization = "ncdv"
    workspaces {
      project = "bootc"
      name    = "Komodo"
    }
  }
}

# required_providers (bpg/proxmox, pinned ~> 0.109) lives in versions.tf.

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = var.proxmox_api_token
  insecure  = true

  # Snippet uploads (cloud-init user-data) cannot use the Proxmox API upload
  # endpoint — it only accepts iso/vztmpl — so the provider transfers them over
  # SSH/SCP. HCP remote runners have no ssh-agent, so authenticate with an
  # explicit username + private key (agent disabled).
  ssh {
    agent       = false
    username    = var.proxmox_ssh_username
    private_key = var.proxmox_ssh_private_key
  }
}
