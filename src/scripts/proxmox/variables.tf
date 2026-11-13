variable "node_name" {
  description = "Proxmox VE node that runs the appliance."
  type        = string
}

variable "appliance_version" {
  description = "Appliance release to deploy, e.g. \"0.1.0\". Part of the image file name on the datastore."
  type        = string
}

variable "image_url" {
  description = "URL of the raw disk image of that release."
  type        = string
}

variable "image_checksum" {
  description = "SHA-256 checksum of the image, from the checksum file of the release."
  type        = string
  default     = null
}

variable "image_datastore_id" {
  description = "Datastore for the downloaded image (needs the \"import\" content type)."
  type        = string
  default     = "local"
}

variable "vm_datastore_id" {
  description = "Datastore for the VM disks."
  type        = string
  default     = "local-lvm"
}

variable "vm_name" {
  description = "VM name and hostname."
  type        = string
  default     = "kamerplanter"
}

variable "disk_size" {
  description = "System disk size in GiB."
  type        = number
  default     = 32
}

variable "cores" {
  description = "CPU cores."
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in MiB."
  type        = number
  default     = 4096
}

variable "network_bridge" {
  description = "Bridge the VM is attached to."
  type        = string
  default     = "vmbr0"
}

variable "ipv4_address" {
  description = "\"dhcp\" or a static address in CIDR notation."
  type        = string
  default     = "dhcp"
}

variable "ipv4_gateway" {
  description = "Gateway for a static address."
  type        = string
  default     = null
}

variable "ssh_public_keys" {
  description = "SSH public keys for administrative access."
  type        = list(string)
  default     = []
}
