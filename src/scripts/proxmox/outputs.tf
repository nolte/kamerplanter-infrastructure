output "vm_id" {
  description = "ID of the appliance VM."
  value       = module.appliance.vm_id
}

output "ipv4_address" {
  description = "IPv4 address of the appliance."
  value       = module.appliance.ipv4_address
}

output "web_ui_url" {
  description = "URL of the Kamerplanter web UI."
  value       = module.appliance.web_ui_url
}
