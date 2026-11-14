# Tests for src/modules/proxmox-appliance-vm against a mocked Proxmox
# provider: no Proxmox VE node is needed.
mock_provider "proxmox" {}

variables {
  node_name     = "pve"
  image_file_id = "local:import/kamerplanter-appliance-0.1.0.raw"
}

run "dhcp_by_default" {
  module {
    source = "../src/modules/proxmox-appliance-vm"
  }

  command = apply

  assert {
    condition     = proxmox_virtual_environment_vm.this.initialization[0].ip_config[0].ipv4[0].address == "dhcp"
    error_message = "The VM must use DHCP by default."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.disk[0].import_from == var.image_file_id
    error_message = "The system disk must be imported from the appliance image."
  }

  assert {
    condition     = output.ipv4_address == "unknown" && output.web_ui_url == null
    error_message = "With DHCP and no guest agent the address is unknown."
  }
}

run "static_address" {
  module {
    source = "../src/modules/proxmox-appliance-vm"
  }

  command = apply

  variables {
    ipv4_address = "192.168.1.50/24"
    ipv4_gateway = "192.168.1.1"
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.initialization[0].ip_config[0].ipv4[0].gateway == "192.168.1.1"
    error_message = "The gateway must be passed through cloud-init."
  }

  assert {
    condition     = output.web_ui_url == "http://192.168.1.50:8080"
    error_message = "The web UI URL must be derived from the static address."
  }
}

run "static_address_requires_gateway" {
  module {
    source = "../src/modules/proxmox-appliance-vm"
  }

  command = plan

  variables {
    ipv4_address = "192.168.1.50/24"
  }

  expect_failures = [var.ipv4_gateway]
}

run "rejects_malformed_address" {
  module {
    source = "../src/modules/proxmox-appliance-vm"
  }

  command = plan

  variables {
    ipv4_address = "192.168.1.50"
  }

  expect_failures = [var.ipv4_address]
}

# The appliance updates itself: an image of another release, newer or older,
# must leave an existing VM and the data on its disk alone.
run "create_for_image_changes" {
  module {
    source = "../src/modules/proxmox-appliance-vm"
  }

  command = apply
}

run "newer_image_keeps_vm" {
  module {
    source = "../src/modules/proxmox-appliance-vm"
  }

  command = plan

  variables {
    image_file_id = "local:import/kamerplanter-appliance-0.2.0.raw"
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.disk[0].import_from == "local:import/kamerplanter-appliance-0.1.0.raw"
    error_message = "A newer image must not change an existing VM."
  }
}

run "older_image_keeps_vm" {
  module {
    source = "../src/modules/proxmox-appliance-vm"
  }

  command = plan

  variables {
    image_file_id = "local:import/kamerplanter-appliance-0.0.9.raw"
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.disk[0].import_from == "local:import/kamerplanter-appliance-0.1.0.raw"
    error_message = "An older image must not roll back an existing VM."
  }
}

run "reinstall_generation_reinstalls_from_image" {
  module {
    source = "../src/modules/proxmox-appliance-vm"
  }

  command = plan

  variables {
    image_file_id        = "local:import/kamerplanter-appliance-0.0.9.raw"
    reinstall_generation = 1
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.disk[0].import_from == "local:import/kamerplanter-appliance-0.0.9.raw"
    error_message = "Raising reinstall_generation must recreate the VM from the given image."
  }
}

run "rejects_fractional_reinstall_generation" {
  module {
    source = "../src/modules/proxmox-appliance-vm"
  }

  command = plan

  variables {
    reinstall_generation = 1.5
  }

  expect_failures = [var.reinstall_generation]
}
