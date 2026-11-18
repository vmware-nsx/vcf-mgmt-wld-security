variable "group_paths" {
  type        = map(string)
  description = "Map of NSX group names to policy path, provided by the groups-and-services module"
}

variable "service_paths" {
  type        = map(string)
  description = "Map of NSX service names to policy path, provided by the groups-and-services module"
}
