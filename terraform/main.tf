##############################################
# web1 y web2 — Debian 13 (backends, solo redes internas)
##############################################
resource "libvirt_volume" "p1-web-disk" {
  for_each         = var.webs
  name             = "p1-${each.key}.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.base_image_debian
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

resource "libvirt_cloudinit_disk" "p1-web-cloudinit" {
  for_each = var.webs
  name     = "p1-${each.key}-cloudinit.iso"
  pool     = var.libvirt_pool_name
  user_data = templatefile("${path.module}/cloud-init/user-data-web.yaml.tftpl", {
    hostname = each.key
  })
  network_config = templatefile("${path.module}/cloud-init/network-config-web.yaml.tftpl", {
    ip_balanceo = each.value.ip_balanceo
    ip_datos    = each.value.ip_datos
    ip_gateway  = var.ip_lb_balanceo
  })
}

resource "libvirt_domain" "p1-web" {
  for_each = var.webs
  name     = "p1-${each.key}"
  memory   = var.memoria_web
  vcpu     = 2

  # ens3: red de balanceo (IP estática; sin red NAT)
  network_interface {
    network_id = libvirt_network.p1-balanceo.id
  }

  # ens4: red de datos (IP estática)
  network_interface {
    network_id = libvirt_network.p1-datos.id
  }

  disk { volume_id = libvirt_volume.p1-web-disk[each.key].id }
  cloudinit = libvirt_cloudinit_disk.p1-web-cloudinit[each.key].id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

##############################################
# lb — Debian 13 (balanceador y router NAT)
##############################################
resource "libvirt_volume" "p1-lb-disk" {
  name             = "p1-lb.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.base_image_debian
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

resource "libvirt_cloudinit_disk" "p1-lb-cloudinit" {
  name      = "p1-lb-cloudinit.iso"
  pool      = var.libvirt_pool_name
  user_data = file("${path.module}/cloud-init/user-data-lb.yaml")
  network_config = templatefile("${path.module}/cloud-init/network-config-lb.yaml.tftpl", {
    ip_balanceo = var.ip_lb_balanceo
  })
}

resource "libvirt_domain" "p1-lb" {
  name   = "p1-lb"
  memory = var.memoria_lb
  vcpu   = 1

  # ens3: red NAT con DHCP (entrada desde el exterior y salida a internet)
  network_interface {
    network_id     = libvirt_network.p1-nat-dhcp.id
    wait_for_lease = true
  }

  # ens4: red de balanceo (hacia los webs)
  network_interface {
    network_id = libvirt_network.p1-balanceo.id
  }

  disk { volume_id = libvirt_volume.p1-lb-disk.id }
  cloudinit = libvirt_cloudinit_disk.p1-lb-cloudinit.id

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
