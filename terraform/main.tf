##############################################
# web — Debian 13
##############################################
resource "libvirt_volume" "p1-web-disk" {
  name             = "p1-web.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.base_image_debian
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

resource "libvirt_cloudinit_disk" "p1-web-cloudinit" {
  name           = "p1-web-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = file("${path.module}/cloud-init/user-data-web.yaml")
  network_config = templatefile("${path.module}/cloud-init/network-config-web.yaml.tftpl", {
    ip_datos = var.ip_web_datos
  })
}

resource "libvirt_domain" "p1-web" {
  name   = "p1-web"
  memory = var.memoria_web
  vcpu   = 2

  # ens3: NAT con DHCP
  network_interface {
    network_id     = libvirt_network.p1-nat-dhcp.id
    wait_for_lease = true
  }

  # ens4: red de datos (IP estática)
  network_interface {
    network_id = libvirt_network.p1-datos.id
  }

  disk { volume_id = libvirt_volume.p1-web-disk.id }
  cloudinit = libvirt_cloudinit_disk.p1-web-cloudinit.id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

##############################################
# bd — Ubuntu 26.04
##############################################
resource "libvirt_volume" "p1-bd-disk" {
  name             = "p1-bd.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.base_image_ubuntu
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

resource "libvirt_cloudinit_disk" "p1-bd-cloudinit" {
  name           = "p1-bd-cloudinit.iso"
  pool           = var.libvirt_pool_name
  user_data      = file("${path.module}/cloud-init/user-data-bd.yaml")
  network_config = templatefile("${path.module}/cloud-init/network-config-bd.yaml.tftpl", {
    ip_datos = var.ip_bd_datos
  })
}

resource "libvirt_domain" "p1-bd" {
  name   = "p1-bd"
  memory = var.memoria_bd
  vcpu   = 2

  network_interface {
    network_id     = libvirt_network.p1-nat-dhcp.id
    wait_for_lease = true
  }

  network_interface {
    network_id = libvirt_network.p1-datos.id
  }

  disk { volume_id = libvirt_volume.p1-bd-disk.id }
  cloudinit = libvirt_cloudinit_disk.p1-bd-cloudinit.id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
