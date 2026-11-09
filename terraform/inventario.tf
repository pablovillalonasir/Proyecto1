# Genera el inventario de Ansible (ansible/hosts) con las IP del escenario
resource "local_file" "inventario" {
  filename        = "${path.module}/../ansible/hosts"
  file_permission = "0644"
  content = templatefile("${path.module}/inventario.tftpl", {
    ip_lb = try(libvirt_domain.p1-lb.network_interface[0].addresses[0], "")
    ip_bd = try(libvirt_domain.p1-bd.network_interface[0].addresses[0], "")
    webs  = var.webs
  })

  # Las IPs de los backends son estáticas por lo que tendremos que esperar a que existan las máquinas
  depends_on = [libvirt_domain.p1-web]

}
