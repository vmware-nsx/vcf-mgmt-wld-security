variable "dns_server" {
  type        = string
  description = "DNS server IP address"
}

variable "ntp_server" {
  type        = string
  description = "NTP server IP address"
}

variable "dhcp_server" {
  type        = string
  description = "DHCP server IP address"
}

variable "ad_server" {
  type        = string
  description = "Active Directory server IP address"
}

variable "group_paths" {
  type        = map(string)
  description = "Map of NSX group names to policy path, provided by the groups-and-services module"
}

variable "service_paths" {
  type        = map(string)
  description = "Map of custom NSX service names to policy path, provided by the groups-and-services module"
}
