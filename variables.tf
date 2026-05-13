variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}
variable "proxmox_username" {
  description = "Proxmox API username"
  type        = string
}
variable "proxmox_password" {
  description = "Proxmox API password"
  type        = string
  sensitive   = true
  nullable    = false
}
variable "proxmox_tls_insecure" {
  description = "Use insecure connection"
  type        = bool
  default     = false
}