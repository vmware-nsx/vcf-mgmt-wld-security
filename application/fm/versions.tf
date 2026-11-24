terraform {
  required_version = ">= 1.6.0"

  required_providers {
    nsxt = {
      source  = "vmware/nsxt"
      version = "~> 3.12"
    }
  }
}
