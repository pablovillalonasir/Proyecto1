# Red NAT con DHCP: salida a internet y acceso desde el host
resource "libvirt_network" "p1-nat-dhcp" {
  name      = "p1-nat-dhcp"
  mode      = "nat"
  domain    = "example.com"
  addresses = ["192.168.120.0/24"]
  dhcp { enabled = true }
  dns { enabled = true }
  autostart = true
}

# Red de datos muy aislada (mode=none, sin addresses): solo web <-> bd
resource "libvirt_network" "p1-datos" {
  name      = "p1-datos"
  mode      = "none"
  autostart = true
}
