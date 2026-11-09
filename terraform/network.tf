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

# Red de datos muy aislada (mode=none, sin addresses): solo webs <-> bd
resource "libvirt_network" "p1-datos" {
  name      = "p1-datos"
  mode      = "none"
  autostart = true
}

# Red de balanceo: muy aislada solo lb <-> webs (lb hace de router).
resource "libvirt_network" "p1-balanceo" {
  name      = "p1-balanceo"
  mode      = "none"
  autostart = true
}
