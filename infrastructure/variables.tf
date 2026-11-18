# Input validation lives on the root module variables (variables.tf).

variable "external_services" {
  type = object({
    dns_server  = string
    ntp_server  = string
    dhcp_server = string
    ad_server   = string
  })
  description = "IP addresses of the DNS, NTP, DHCP and Active Directory servers the fleet may use (the root module passes its full external_services object; only these attributes are read)"
}

variable "group_paths" {
  type        = map(string)
  description = "Map of NSX group names to policy path, provided by the groups-and-services module"
}

variable "service_paths" {
  type        = map(string)
  description = "Map of NSX service names to policy path, provided by the groups-and-services module"
}

variable "context_profile_paths" {
  type        = map(string)
  description = "Map of NSX context profile names to policy path, provided by the groups-and-services module"
}
