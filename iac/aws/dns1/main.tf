################################################################################
# Root Module - Clean Code: Single Responsibility
# This file instantiates the DNS server module with clear, readable parameters.
################################################################################

module "dns1" {
  source = "../../../modules/aws_dns_vm"

  # AWS Configuration
  aws_region   = var.aws_region
  ami_map      = var.ami_map
  ami_default  = var.ami_default

  # Compute Configuration
  instance_type = var.compute.instance_type
  name          = local.service_name
  key_name      = var.key_pair_name
  volume_size   = var.compute.volume_size

  # Networking Configuration
  vpc_id     = var.networking.vpc_id
  subnet_id  = var.networking.subnet_id
  private_ip = var.networking.private_ip

  # Provisioning Configuration
  user_data = local.cloud_init_config

  # Security Configuration
  allowed_ssh_cidrs = var.security_config.allowed_ssh_cidrs
  dns_allowed_cidrs = var.security_config.dns_allowed_cidrs
  assign_eip        = var.networking.assign_eip
}
