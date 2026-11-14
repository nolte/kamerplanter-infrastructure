# Tests for src/modules/proxmox-appliance-image against a mocked
# Proxmox provider: no Proxmox VE node is needed.
mock_provider "proxmox" {}

variables {
  node_name = "pve"
  image_url = "https://github.com/nolte/kamerplanter-appliance/releases/download/v0.1.0/disk.raw"
  file_name = "kamerplanter-appliance-0.1.0.raw"
}

run "downloads_as_importable_disk" {
  module {
    source = "../src/modules/proxmox-appliance-image"
  }

  command = plan

  assert {
    condition     = proxmox_download_file.this.content_type == "import"
    error_message = "The image must be stored with the import content type."
  }

  assert {
    condition     = proxmox_download_file.this.datastore_id == "local"
    error_message = "The default datastore must be local."
  }

  assert {
    condition     = proxmox_download_file.this.checksum_algorithm == null
    error_message = "Without a checksum no algorithm may be set."
  }
}

run "verifies_checksum_when_given" {
  module {
    source = "../src/modules/proxmox-appliance-image"
  }

  command = plan

  variables {
    checksum = "0000000000000000000000000000000000000000000000000000000000000000"
  }

  assert {
    condition     = proxmox_download_file.this.checksum_algorithm == "sha256"
    error_message = "A checksum must be verified as SHA-256."
  }
}

run "rejects_plain_http" {
  module {
    source = "../src/modules/proxmox-appliance-image"
  }

  command = plan

  variables {
    image_url = "http://example.org/disk.raw"
  }

  expect_failures = [var.image_url]
}

run "rejects_file_name_without_disk_extension" {
  module {
    source = "../src/modules/proxmox-appliance-image"
  }

  command = plan

  variables {
    file_name = "kamerplanter-appliance.iso"
  }

  expect_failures = [var.file_name]
}

run "rejects_malformed_checksum" {
  module {
    source = "../src/modules/proxmox-appliance-image"
  }

  command = plan

  variables {
    checksum = "not-a-sha256"
  }

  expect_failures = [var.checksum]
}

run "does_not_recheck_upstream" {
  module {
    source = "../src/modules/proxmox-appliance-image"
  }

  command = plan

  assert {
    condition     = proxmox_download_file.this.overwrite == false
    error_message = "An existing image must not depend on the upstream URL staying reachable."
  }
}
