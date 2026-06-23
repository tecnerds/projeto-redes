variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ami_map" {
  description = "Map of AMIs per region"
  type        = map(string)
  default     = {}
}

variable "ami_default" {
  description = "Fallback AMI if region not present in ami_map"
  type        = string
  default     = ""
}

variable "ssm_ami_parameter" {
  description = "SSM parameter name to fetch a default AMI when ami_map and ami_default are not set"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "name" {
  description = "Instance name tag"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "vpc_id" {
  description = "VPC id where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet id to launch the instance"
  type        = string
}

variable "private_ip" {
  description = "Private IP for the instance (optional)"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "Cloud-init / user data content"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDRs allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "dns_allowed_cidrs" {
  description = "List of CIDRs allowed for DNS (53/tcp & udp)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "volume_size" {
  description = "Root EBS volume size (GB)"
  type        = number
  default     = 8
}

variable "assign_eip" {
  description = "Whether to allocate and associate an Elastic IP"
  type        = bool
  default     = false
}
