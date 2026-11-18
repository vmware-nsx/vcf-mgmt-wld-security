variable "group_paths" {
  type        = map(string)
  description = "Map of NSX group names to policy path, provided by the groups-and-services module"
}

variable "service_paths" {
  type        = map(string)
  description = "Map of NSX service names to policy path, provided by the groups-and-services module"
}

variable "ssp_enabled" {
  type        = bool
  default     = false
  description = "Create the Workload Domain 01 SSP policy. True when var.w01.ssp is set in the root module (SSP deployed on w01); the w01_sspi/w01_ssp/w01_ssp_svc groups exist only then"
}
