module "image" {
  source = "../../modules/proxmox-appliance-image"

  node_name    = var.node_name
  datastore_id = var.image_datastore_id
  image_url    = var.image_url
  file_name    = "kamerplanter-appliance-${var.appliance_version}.raw"
  checksum     = var.image_checksum
}

module "appliance" {
  source = "../../modules/proxmox-appliance-vm"

  node_name     = var.node_name
  name          = var.vm_name
  image_file_id = module.image.file_id
  # Explicit reinstall from appliance_version; destroys all data on the VM.
  reinstall_generation = var.reinstall_generation
  datastore_id         = var.vm_datastore_id
  disk_size            = var.disk_size
  cores                = var.cores
  memory               = var.memory
  network_bridge       = var.network_bridge
  ipv4_address         = var.ipv4_address
  ipv4_gateway         = var.ipv4_gateway
  ssh_public_keys      = var.ssh_public_keys
}
