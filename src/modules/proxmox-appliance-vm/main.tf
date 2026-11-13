locals {
  static_ipv4 = var.ipv4_address == "dhcp" ? null : split("/", var.ipv4_address)[0]

  # Addresses reported by the QEMU guest agent, without loopback.
  agent_ipv4 = var.agent_enabled ? [
    for ip in flatten(proxmox_virtual_environment_vm.this.ipv4_addresses) : ip
    if ip != "127.0.0.1"
  ] : []

  ipv4 = coalesce(local.static_ipv4, try(local.agent_ipv4[0], null), "unknown")
}

resource "proxmox_virtual_environment_vm" "this" {
  node_name   = var.node_name
  vm_id       = var.vm_id
  name        = var.name
  description = var.description
  tags        = var.tags

  on_boot = var.start_on_boot
  started = true

  machine       = "q35"
  bios          = "seabios"
  scsi_hardware = "virtio-scsi-single"

  operating_system {
    type = "l26"
  }

  agent {
    enabled = var.agent_enabled
  }

  cpu {
    cores = var.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory
  }

  # System disk, imported from the appliance image. The appliance grows its
  # file system to the full disk at first boot.
  disk {
    interface    = "scsi0"
    datastore_id = var.datastore_id
    import_from  = var.image_file_id
    size         = var.disk_size
    iothread     = true
    discard      = "on"
    ssd          = true
  }

  network_device {
    model   = "virtio"
    bridge  = var.network_bridge
    vlan_id = var.vlan_id
  }

  # Provisioning data in NoCloud format. The appliance reads hostname, SSH
  # keys, and network configuration from it and otherwise falls back to DHCP.
  initialization {
    datastore_id = var.datastore_id

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_address == "dhcp" ? null : var.ipv4_gateway
      }
    }

    dynamic "dns" {
      for_each = length(var.dns_servers) > 0 ? [1] : []
      content {
        servers = var.dns_servers
      }
    }

    user_account {
      keys = var.ssh_public_keys
    }
  }

  lifecycle {
    # The appliance updates itself. A newer image must not replace a running
    # VM and with it the data on its disk; it only applies to new VMs.
    ignore_changes = [disk[0].import_from]
  }
}
