################################################################################
# Outputs - Clean Code: Expose only what is necessary
# Organized by purpose with clear descriptions and examples
################################################################################

output "instance_id" {
  description = "EC2 instance ID of the DNS server"
  value       = module.dns1.instance_id
}

output "private_ip" {
  description = "Private IPv4 address of the DNS server"
  value       = module.dns1.private_ip
}

output "public_ip" {
  description = "Public IPv4 address for SSH and DNS queries"
  value       = module.dns1.public_ip
}

output "security_group_id" {
  description = "Security group ID for network rule management"
  value       = module.dns1.security_group_id
}

output "ssh_command" {
  description = "SSH command to connect to instance (copy and paste ready)"
  value       = "ssh -i certificados/certificado-movel.pem ubuntu@${module.dns1.public_ip}"
}

output "dns_server_config" {
  description = "Complete DNS server configuration summary for reference"
  value = {
    instance_id      = module.dns1.instance_id
    instance_name    = local.service_name
    private_ip       = module.dns1.private_ip
    public_ip        = module.dns1.public_ip
    region           = var.aws_region
    environment      = var.environment_tag
    zone             = "empresa.local"
    dns_records      = local.dns_record_ips
  }
}

# Backward compatibility outputs
output "dns1_private_ip" {
  description = "DEPRECATED: Use 'private_ip' output instead"
  value       = module.dns1.private_ip
}

output "dns1_public_ip" {
  description = "DEPRECATED: Use 'public_ip' output instead"
  value       = module.dns1.public_ip
}
