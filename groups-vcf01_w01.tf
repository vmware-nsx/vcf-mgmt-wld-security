data "nsxt_policy_vm" "vm17" {
  display_name = var.w01_vcenter
}

data "nsxt_policy_vm" "vm18" {
  display_name = var.w01_nsx_manager_a
}

#data "nsxt_policy_vm" "vm19" {
#  display_name = var.w01_nsx_manager_b
#}
#
#data "nsxt_policy_vm" "vm20" {
#  display_name = var.w01_nsx_manager_c
#}

data "nsxt_policy_vm" "vm21" {
  display_name = var.w01_avi_controller_a
}

data "nsxt_policy_vm" "vm22" {
  display_name = var.w01_avi_controller_a
}

data "nsxt_policy_vm" "vm23" {
  display_name = var.w01_avi_controller_a
}

resource "nsxt_policy_vm_tags" "vm17_tags" {
  instance_id = data.nsxt_policy_vm.vm17.id

  tag {
    scope = "w01"
    tag   = "vc01"
  }
}

resource "nsxt_policy_vm_tags" "vm18_tags" {
  instance_id = data.nsxt_policy_vm.vm18.id

  tag {
    scope = "w01"
    tag   = "nsx01"
  }
}

#resource "nsxt_policy_vm_tags" "vm19_tags" {
#  instance_id = data.nsxt_policy_vm.vm19.id
#
#  tag {
#    scope = "w01"
#    tag   = "nsx01"
#  }
#}
#
#resource "nsxt_policy_vm_tags" "vm20_tags" {
#  instance_id = data.nsxt_policy_vm.vm20.id
#
#  tag {
#    scope = "w01"
#    tag   = "nsx01"
#  }
#}

resource "nsxt_policy_vm_tags" "vm21_tags" {
  instance_id = data.nsxt_policy_vm.vm21.id

  tag {
    scope = "w01"
    tag   = "avi01"
  }
}

#resource "nsxt_policy_vm_tags" "vm22_tags" {
#  instance_id = data.nsxt_policy_vm.vm22.id
#
#  tag {
#    scope = "w01"
#    tag   = "avi01"
#  }
#}
#
#resource "nsxt_policy_vm_tags" "vm23_tags" {
#  instance_id = data.nsxt_policy_vm.vm23.id
#
#  tag {
#    scope = "w01"
#    tag   = "avi01"
#  }
#}

resource "nsxt_policy_group" "w01_vc" {
  nsx_id       = "W01_VC"
  display_name = "W01_VC"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Name"
      operator    = "STARTSWITH"
      value       = var.w01_vcenter
    }
  }
}

resource "nsxt_policy_group" "w01_nsx" {
  nsx_id       = "W01_NSX"
  display_name = "W01_NSX"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "w01|nsx01"
    }
  }
  
  conjunction {
    operator = "OR"
  }

  criteria {
    ipaddress_expression {
      ip_addresses = ["172.16.10.54-172.16.10.55"]
    }
  }
}

resource "nsxt_policy_group" "w01_avi" {
  nsx_id       = "W01_AVI"
  display_name = "W01_AVI"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "w01|avi01"
    }
  }
}

resource "nsxt_policy_group" "w01_avi_se" {
  nsx_id       = "W01_AVI_SE"
  display_name = "W01_AVI_SE"
  
  criteria {
    ipaddress_expression {
      ip_addresses = ["172.16.23.11-172.16.23.100"]
    }
  }
}

resource "nsxt_policy_group" "w01_edges" {
  nsx_id       = "W01_EDGES"
  display_name = "W01_EDGES"
  group_type   = "IPAddress"
  
  tag {
    scope = "w01"
    tag   = "edges"
  }

  criteria {
    ipaddress_expression {
      ip_addresses = [var.w01_edges]
    }
  }
}

resource "nsxt_policy_group" "w01_hosts" {
  nsx_id       = "W01_HOSTS"
  display_name = "W01_HOSTS"
  group_type   = "IPAddress"
  
  tag {
    scope = "w01"
    tag   = "hosts"
  }

  criteria {
    ipaddress_expression {
      ip_addresses = [var.w01_hosts]
    }
  }
}

resource "nsxt_policy_group" "w01_sup01" {
  nsx_id       = "W01_SUP01"
  display_name = "W01_SUP01"
  group_type   = "IPAddress"

  tag {
    scope = "w01"
    tag   = "sup01"
  }

  criteria {
    ipaddress_expression {
      ip_addresses = [var.w01_sup01]
    }
  }
}

# W01_WLD workload domain SSP

data "nsxt_policy_vm" "vm24" {
  display_name = var.w01_sspi_vm
}

resource "nsxt_policy_vm_tags" "vm24_tags" {
  instance_id = data.nsxt_policy_vm.vm24.id

  tag {
    scope = "w01"
    tag   = "sspi01"
  }
}

resource "nsxt_policy_group" "w01_sspi" {
  nsx_id       = "W01_SSPI"
  display_name = "W01_SSPI"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "w01|sspi01"
    }
  }
}

resource "nsxt_policy_group" "w01_ssp" {
  nsx_id       = "W01_SSP"
  display_name = "W01_SSP"

  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Name"
      operator    = "STARTSWITH"
      value       = "w01-ssp-"
    }
  }
}

resource "nsxt_policy_group" "w01_sspm" {
  nsx_id       = "W01_SSPM"
  display_name = "W01_SSPM"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.w01_sspm]
    }
  }
}


resource "nsxt_policy_group" "vcf01_w01" {
  nsx_id       = "VCF01_W01"
  display_name = "VCF01_W01"

  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "w01|"
    }
  }

  conjunction {
    operator = "OR"
  }

  criteria {
    condition {
	  member_type = "Group"
	  key         = "GroupType"
	  operator    = "EQUALS"
      value       = "IPAddress"
    }
    condition {
      member_type = "Group"
	  key         = "Tag"
      operator    = "EQUALS"
      value       = "w01|"
    }
  }
  
  conjunction {
    operator = "OR"
  }

  criteria {
    path_expression {
      member_paths = [nsxt_policy_group.w01_vc.path,nsxt_policy_group.w01_ssp.path]
    }
  }
}


