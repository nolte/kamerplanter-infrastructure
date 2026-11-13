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
