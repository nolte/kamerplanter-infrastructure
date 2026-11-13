output "vm_id" {
  description = "ID of the VM."
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "name" {
  description = "Name and hostname of the VM."
  value       = proxmox_virtual_environment_vm.this.name
}

output "ipv4_address" {
  description = "IPv4 address of the appliance: the static address, the one reported by the guest agent, or \"unknown\" with DHCP and no agent."
  value       = local.ipv4
}

output "web_ui_url" {
  description = "URL of the Kamerplanter web UI, null while the address is unknown."
  value       = local.ipv4 == "unknown" ? null : "http://${local.ipv4}:8080"
}
