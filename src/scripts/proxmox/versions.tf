terraform {
  required_version = ">= 1.9"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.122"
    }
  }
}

# Endpoint and credentials come from the environment:
#   PROXMOX_VE_ENDPOINT   e.g. https://pve.example.lan:8006/
#   PROXMOX_VE_API_TOKEN  e.g. terraform@pve!kamerplanter=<secret>
#   PROXMOX_VE_INSECURE   true when the node uses a self-signed certificate
provider "proxmox" {}
