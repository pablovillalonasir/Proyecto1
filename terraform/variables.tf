variable "libvirt_pool_name" {
  type        = string
  description = "Nombre del pool de almacenamiento libvirt."
  default     = "default"
}

variable "base_image_debian" {
  type        = string
  description = "Imagen base Debian para web."
  default     = "debian-13-generic-amd64.qcow2"
}

variable "base_image_ubuntu" {
  type        = string
  description = "Imagen base Ubuntu para bd."
  default     = "ubuntu2604-base.qcow2"
}

variable "memoria_web" {
  type        = number
  description = "Memoria (MB) de la máquina web."
  default     = 1024
}

variable "memoria_bd" {
  type        = number
  description = "Memoria (MB) de la máquina bd."
  default     = 1024
}

# IPs estáticas de la red de datos: una sola vez aquí, se usan en cloud-init y en output
variable "ip_web_datos" {
  type    = string
  default = "10.0.0.1"
}

variable "ip_bd_datos" {
  type    = string
  default = "10.0.0.2"
}
