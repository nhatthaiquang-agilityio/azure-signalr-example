variable "environment" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "signalr_name" {
    type = string
}

variable "allowed_origins" {
  type = list(string)
  default = []
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "pv_endpoint_static_ip" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {
    app-name = "Az SignalR"
  }
}

variable "pv_endpoint_name" {
  type = string
  default = ""
}
variable "pv_svc_connection_signalr" {
  type = string
  default = ""
}

variable "pv_dns_zone_group_signalr" {
  type = string
  default = "signalr-dns-zone-group"
}

variable "network_interface_signalr" {
  type = string
  default = ""
}