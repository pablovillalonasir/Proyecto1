output "lb" {
  value = {
    nombre      = "p1-lb"
    ip_nat      = try(libvirt_domain.p1-lb.network_interface[0].addresses[0], "No disponible")
    ip_balanceo = var.ip_lb_balanceo
  }
}

output "webs" {
  value = {
    for k, w in var.webs : k => {
      nombre      = "p1-${k}"
      ip_balanceo = w.ip_balanceo
      ip_datos    = w.ip_datos
    }
  }
}

output "bd" {
  value = {
    nombre   = "p1-bd"
    ip_nat   = try(libvirt_domain.p1-bd.network_interface[0].addresses[0], "No disponible")
    ip_datos = var.ip_bd_datos
  }
}
