terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.9"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_api_token_id = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  tls_insecure    = var.tls_insecure
}

resource "proxmox_vm_qemu" "dns1" {
  name        = var.name
  target_node = var.target_node
  clone       = var.template
  full_clone  = true

  cores  = var.cores
  memory = var.memory

  disk {
    size    = var.disk_size
    type    = "scsi"
    storage = var.storage
  }

  network {
    model  = "virtio"
    bridge = var.bridge
  }

  # IP config via cloud-init / ipconfig0
  ipconfig0 = "ip=${var.ip}/${var.netmask},gw=${var.gateway}"

  # SSH public key to inject
  sshkeys = file(var.ssh_pub_key)

  # cloud-init user data (some provider versions support user_data)
  user_data = file("${path.module}/provision-cloudinit.yml")

  # Optional: wait for SSH
  timeout = "20m"
}
