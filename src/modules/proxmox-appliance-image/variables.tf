variable "node_name" {
  description = "Proxmox VE node that downloads and stores the image."
  type        = string
}

variable "datastore_id" {
  description = "Datastore that holds the image. It must allow the \"import\" content type (a directory-based storage such as \"local\")."
  type        = string
  default     = "local"
}

variable "image_url" {
  description = "Download URL of the raw appliance disk image, normally a release asset of nolte/kamerplanter-appliance."
  type        = string

  validation {
    condition     = can(regex("^https://", var.image_url))
    error_message = "image_url must be an https URL."
  }
}

variable "file_name" {
  description = "File name of the image on the datastore. Include the appliance version so that a new release does not overwrite the image of the old one."
  type        = string

  validation {
    condition     = can(regex("\\.(raw|qcow2|vmdk)$", var.file_name))
    error_message = "file_name must end in .raw, .qcow2, or .vmdk, as Proxmox VE requires for importable disks."
  }
}

variable "checksum" {
  description = "Expected SHA-256 checksum of the image, from the checksum file of the release. Proxmox VE rejects the download on a mismatch. Leave null only for testing."
  type        = string
  default     = null

  validation {
    condition     = var.checksum == null || can(regex("^[0-9a-f]{64}$", var.checksum))
    error_message = "checksum must be a lowercase hex SHA-256 digest."
  }
}

variable "download_timeout" {
  description = "Seconds Proxmox VE may take to download the image."
  type        = number
  default     = 1800
}
