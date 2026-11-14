# Downloads the appliance disk image onto a Proxmox VE datastore as an
# importable disk ("import" content type). VMs created by the
# proxmox-appliance-vm module import their system disk from this file.
resource "proxmox_download_file" "this" {
  node_name    = var.node_name
  datastore_id = var.datastore_id
  content_type = "import"
  url          = var.image_url
  file_name    = var.file_name

  checksum           = var.checksum
  checksum_algorithm = var.checksum == null ? null : "sha256"

  upload_timeout = var.download_timeout

  # The file name carries the release version and the checksum pins the
  # content, so the upstream URL is not checked again on every refresh. An
  # existing image stays in place even when its release asset is gone.
  overwrite = false
}
