variable "group_paths" {
  type        = map(string)
  description = "Map of NSX group names to policy path, provided by the groups-and-services module"
}

variable "service_paths" {
  type        = map(string)
  description = "Map of custom NSX service names to policy path, provided by the groups-and-services module"
}

variable "context_profile_paths" {
  type        = map(string)
  description = "Map of custom NSX context profile names to policy path, provided by the groups-and-services module"
}
