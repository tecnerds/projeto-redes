################################################################################
# Local Values - Clean Code Principle: DRY
# Computed values derived from input variables, improving maintainability
################################################################################

locals {
  # Service metadata
  service_name = var.instance_name
  environment  = var.environment_tag

  # Resource naming convention for consistency
  resource_name_prefix = "${local.service_name}-${local.environment}"

  # Common tags applied to all resources
  common_tags = {
    Name        = local.service_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Project     = "projeto-redes"
  }

  # DNS configuration - resolve user-provided IPs or fallback to private IP
  # Single responsibility: DNS IP computation
  dns_record_ips = {
    dns = var.dns_ip != "" ? var.dns_ip : var.networking.private_ip
    srv = var.srv_ip != "" ? var.srv_ip : var.networking.private_ip
    web = var.web_ip != "" ? var.web_ip : var.networking.private_ip
  }

  # Cloud-init user data - template rendering centralized
  # Improves testability and reusability
  cloud_init_config = templatefile("${path.module}/provision-cloudinit.yml", {
    dns_ip = local.dns_record_ips.dns
    srv_ip = local.dns_record_ips.srv
    web_ip = local.dns_record_ips.web
  })
}
