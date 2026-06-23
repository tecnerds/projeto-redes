################################################################################
# Variables - Clean Code Principle: Self-Documenting
# Organized by domain (AWS, Instance, Networking, Security, DNS)
# All variables include validation rules for early error detection
################################################################################

################################################################################
# AWS Configuration
################################################################################

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d{1}$", var.aws_region))
    error_message = "AWS region must be in valid format (e.g., us-east-1, eu-west-1)"
  }
}

variable "environment_tag" {
  description = "Environment tag for resource organization and tracking"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment_tag)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

################################################################################
# Instance Configuration
################################################################################

variable "instance_name" {
  description = "Name of the DNS server instance for identification and tagging"
  type        = string
  default     = "dns1"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,62}[a-z0-9]$", var.instance_name))
    error_message = "Instance name must be lowercase alphanumeric with hyphens, between 3-64 characters"
  }
}

variable "compute" {
  description = "Compute configuration for EC2 instance"
  type = object({
    instance_type = string
    volume_size   = number
  })

  default = {
    instance_type = "t3.micro"
    volume_size   = 8
  }

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium", "t3.large", "t3.xlarge"], var.compute.instance_type)
    error_message = "Instance type must be a valid t3 instance (micro, small, medium, large, xlarge)"
  }

  validation {
    condition     = var.compute.volume_size >= 8 && var.compute.volume_size <= 1000
    error_message = "Volume size must be between 8 and 1000 GB"
  }
}

variable "key_pair_name" {
  description = "EC2 key pair name for SSH access (must exist in target region)"
  type        = string

  validation {
    condition     = length(var.key_pair_name) > 0
    error_message = "Key pair name is required and cannot be empty"
  }
}

variable "ami_map" {
  description = "Map of Ubuntu AMI IDs by region (optional override for custom AMIs)"
  type        = map(string)
  default     = {}
}

variable "ami_default" {
  description = "Default Ubuntu AMI ID if not found in ami_map (optional override)"
  type        = string
  default     = ""
}

################################################################################
# Networking Configuration
################################################################################

variable "networking" {
  description = "Networking configuration for instance"
  type = object({
    vpc_id     = string
    subnet_id  = string
    private_ip = string
    assign_eip = bool
  })

  default = {
    vpc_id     = ""
    subnet_id  = ""
    private_ip = "10.0.1.10"
    assign_eip = false
  }

  validation {
    condition     = can(regex("^vpc-[a-z0-9]{8,17}$", var.networking.vpc_id)) || var.networking.vpc_id == ""
    error_message = "VPC ID must be in format vpc-xxxxxxxx or empty string"
  }

  validation {
    condition     = can(regex("^subnet-[a-z0-9]{8,17}$", var.networking.subnet_id)) || var.networking.subnet_id == ""
    error_message = "Subnet ID must be in format subnet-xxxxxxxx or empty string"
  }

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.networking.private_ip))
    error_message = "Private IP must be a valid IPv4 address"
  }
}

################################################################################
# Security Configuration
################################################################################

variable "security_config" {
  description = "Security configuration including CIDR rules for network access"
  type = object({
    allowed_ssh_cidrs = list(string)
    dns_allowed_cidrs = list(string)
  })

  default = {
    allowed_ssh_cidrs = ["0.0.0.0/0"]
    dns_allowed_cidrs = ["0.0.0.0/0"]
  }

  validation {
    condition = alltrue([
      for cidr in var.security_config.allowed_ssh_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All SSH CIDRs must be valid CIDR notation (e.g., 10.0.0.0/8, 192.168.1.0/24)"
  }

  validation {
    condition = alltrue([
      for cidr in var.security_config.dns_allowed_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All DNS CIDRs must be valid CIDR notation (e.g., 10.0.0.0/8, 192.168.1.0/24)"
  }

  validation {
    condition     = length(var.security_config.allowed_ssh_cidrs) > 0
    error_message = "At least one SSH CIDR must be specified"
  }

  validation {
    condition     = length(var.security_config.dns_allowed_cidrs) > 0
    error_message = "At least one DNS CIDR must be specified"
  }
}

################################################################################
# DNS Configuration
################################################################################

variable "dns_ip" {
  description = <<-EOT
    IPv4 address for DNS A record (optional).
    If empty, uses private_ip from networking configuration.
    Example: "10.0.1.100"
  EOT
  type        = string
  default     = ""

  validation {
    condition = var.dns_ip == "" || can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.dns_ip))
    error_message = "DNS IP must be empty or a valid IPv4 address"
  }
}

variable "srv_ip" {
  description = <<-EOT
    IPv4 address for SRV01 A record (optional).
    If empty, uses private_ip from networking configuration.
    Example: "10.0.1.101"
  EOT
  type        = string
  default     = ""

  validation {
    condition = var.srv_ip == "" || can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.srv_ip))
    error_message = "SRV IP must be empty or a valid IPv4 address"
  }
}

variable "web_ip" {
  description = <<-EOT
    IPv4 address for WEB A record (optional).
    If empty, uses private_ip from networking configuration.
    Example: "10.0.1.102"
  EOT
  type        = string
  default     = ""

  validation {
    condition = var.web_ip == "" || can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.web_ip))
    error_message = "Web IP must be empty or a valid IPv4 address"
  }
}
