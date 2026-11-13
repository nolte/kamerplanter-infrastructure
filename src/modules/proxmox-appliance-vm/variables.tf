variable "node_name" {
  description = "Proxmox VE node that runs the VM."
  type        = string
}

variable "name" {
  description = "VM name, also used as hostname of the appliance."
  type        = string
  default     = "kamerplanter"
}

variable "vm_id" {
  description = "VM ID. Null lets Proxmox VE pick the next free one."
  type        = number
  default     = null
}

variable "description" {
  description = "Description shown in the Proxmox VE web interface."
  type        = string
  default     = "Kamerplanter appliance, managed by Terraform"
}

variable "tags" {
  description = "Tags of the VM."
  type        = list(string)
  default     = ["kamerplanter"]
}

variable "image_file_id" {
  description = "Volume ID of the appliance image, the file_id output of proxmox-appliance-image. Only read when the VM is created."
  type        = string
}

variable "datastore_id" {
  description = "Datastore for the system disk and the cloud-init drive."
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  description = "Size of the system disk in GiB. It holds the operating system and all Kamerplanter data."
  type        = number
  default     = 32
}

variable "cores" {
  description = "Number of CPU cores."
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in MiB."
  type        = number
  default     = 4096
}

variable "network_bridge" {
  description = "Proxmox VE bridge the VM is attached to."
  type        = string
  default     = "vmbr0"
}

variable "vlan_id" {
  description = "VLAN tag on the bridge. Null for untagged."
  type        = number
  default     = null
}

variable "ipv4_address" {
  description = "\"dhcp\", or a static address in CIDR notation such as \"192.168.1.50/24\"."
  type        = string
  default     = "dhcp"

  validation {
    condition     = var.ipv4_address == "dhcp" || can(cidrhost(var.ipv4_address, 0))
    error_message = "ipv4_address must be \"dhcp\" or an address in CIDR notation."
  }
}

variable "ipv4_gateway" {
  description = "IPv4 gateway. Required with a static ipv4_address, ignored with DHCP."
  type        = string
  default     = null

  validation {
    condition     = var.ipv4_address == "dhcp" || var.ipv4_gateway != null
    error_message = "ipv4_gateway is required when ipv4_address is static."
  }
}

variable "dns_servers" {
  description = "DNS servers. Empty uses those of the Proxmox VE host or DHCP."
  type        = list(string)
  default     = []
}

variable "ssh_public_keys" {
  description = "SSH public keys for administrative access to the appliance."
  type        = list(string)
  default     = []
}

variable "agent_enabled" {
  description = "Enable the QEMU guest agent. Only enable it if the appliance image ships the agent; otherwise Terraform waits for it until it times out."
  type        = bool
  default     = false
}

variable "start_on_boot" {
  description = "Start the VM when the Proxmox VE node boots."
  type        = bool
  default     = true
}
