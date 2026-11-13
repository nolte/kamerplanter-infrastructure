output "file_id" {
  description = "Volume ID of the downloaded image, for the image_file_id input of proxmox-appliance-vm."
  value       = proxmox_download_file.this.id
}
