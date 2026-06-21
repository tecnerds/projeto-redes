variable "pm_api_url" {
  description = "Proxmox API URL, ex: https://proxmox.example.com:8006/api2/json"
  type        = string
}

variable "pm_api_token_id" {
  description = "Proxmox API token id (user@realm!tokenid)"
  type        = string
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "tls_insecure" {
  description = "Skip TLS verification (true/false)"
  type        = bool
  default     = false
}

variable "target_node" { type = string }
variable "template" { type = string }
variable "name" { type = string }
variable "cores" { type = number  default = 1 }
variable "memory" { type = number default = 1024 }
variable "disk_size" { type = string default = "8G" }
variable "storage" { type = string }
variable "bridge" { type = string }

variable "ip" { type = string }
variable "netmask" { type = string default = "24" }
variable "gateway" { type = string }

variable "ssh_pub_key" { type = string default = "~/.ssh/id_rsa.pub" }
