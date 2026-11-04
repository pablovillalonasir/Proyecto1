output "web" {
  value = {
    nombre   = "p1-web"
    ip_nat   = try(libvirt_domain.p1-web.network_interface[0].addresses[0], "No disponible")
    ip_datos = var.ip_web_datos
  }
}

output "bd" {
  value = {
    nombre   = "p1-bd"
    ip_nat   = try(libvirt_domain.p1-bd.network_interface[0].addresses[0], "No disponible")
    ip_datos = var.ip_bd_datos
  }
}
