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
  insecure  = false
}
