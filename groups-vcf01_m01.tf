data "nsxt_policy_vm" "vm9" {
  display_name = var.m01_vcenter
}

data "nsxt_policy_vm" "vm10" {
  display_name = var.m01_nsx_manager_a
}

#data "nsxt_policy_vm" "vm11" {
#  display_name = var.m01_nsx_manager_b
#}

#data "nsxt_policy_vm" "vm12" {
#  display_name = var.m01_nsx_manager_c
#}

data "nsxt_policy_vm" "vm13" {
  display_name = var.m01_avi_controller_a
}

#data "nsxt_policy_vm" "vm14" {
#  display_name = var.m01_avi_controller_b
#}
#
#data "nsxt_policy_vm" "vm15" {
#  display_name = var.m01_avi_controller_c
#}

resource "nsxt_policy_vm_tags" "vm9_tags" {
  instance_id = data.nsxt_policy_vm.vm9.id

  tag {
    scope = "m01"
    tag   = "vc01"
  }
}

resource "nsxt_policy_vm_tags" "vm10_tags" {
  instance_id = data.nsxt_policy_vm.vm10.id

  tag {
    scope = "m01"
    tag   = "nsx01"
  }
}

#resource "nsxt_policy_vm_tags" "vm11_tags" {
#  instance_id = data.nsxt_policy_vm.vm11.id
#
#  tag {
#    scope = "m01"
#    tag   = "nsx01"
#  }
#}
#
#resource "nsxt_policy_vm_tags" "vm12_tags" {
#  instance_id = data.nsxt_policy_vm.vm12.id
#
#  tag {
#    scope = "m01"
#    tag   = "nsx01"
#  }
#}

resource "nsxt_policy_vm_tags" "vm13_tags" {
  instance_id = data.nsxt_policy_vm.vm13.id

  tag {
    scope = "m01"
    tag   = "avi01"
  }
}

#resource "nsxt_policy_vm_tags" "vm14_tags" {
#  instance_id = data.nsxt_policy_vm.vm14.id
#
#  tag {
#    scope = "m01"
#    tag   = "avi01"
#  }
#}
#
#resource "nsxt_policy_vm_tags" "vm15_tags" {
#  instance_id = data.nsxt_policy_vm.vm15.id
#
#  tag {
#    scope = "m01"
#    tag   = "avi01"
#  }
#}

resource "nsxt_policy_group" "m01_vc" {
  nsx_id       = "M01_VC"
  display_name = "M01_VC"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Name"
      operator    = "STARTSWITH"
      value       = var.m01_vcenter
    }
  }
}

resource "nsxt_policy_group" "m01_nsx" {
  nsx_id       = "M01_NSX"
  display_name = "M01_NSX"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "m01|nsx01"
    }
  }

  conjunction {
    operator = "OR"
  }

  criteria {
    ipaddress_expression {
      ip_addresses = ["172.16.10.50-172.16.10.51"]
    }
  }
}

resource "nsxt_policy_group" "m01_avi" {
  nsx_id       = "M01_AVI"
  display_name = "M01_AVI"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "m01|avi01"
    }
  }
}

resource "nsxt_policy_group" "m01_avi_se" {
  nsx_id       = "M01_AVI_SE"
  display_name = "M01_AVI_SE"
  group_type   = "IPAddress"
  
  tag {
    scope = "m01"
    tag   = "avi_se"
  }
  
  criteria {
    ipaddress_expression {
      ip_addresses = ["172.16.22.11-172.16.22.100"]
    }
  }
}

resource "nsxt_policy_group" "m01_edges" {
  nsx_id       = "M01_EDGES"
  display_name = "M01_EDGES"
  group_type   = "IPAddress"
  
  tag {
    scope = "m01"
    tag   = "edges"
  }

  criteria {
    ipaddress_expression {
      ip_addresses = [var.m01_edges]
    }
  }
}

resource "nsxt_policy_group" "m01_hosts" {
  nsx_id       = "M01_HOSTS"
  display_name = "M01_HOSTS"
  group_type   = "IPAddress"

  tag {
    scope = "m01"
    tag   = "hosts"
  }

  criteria {
    ipaddress_expression {
      ip_addresses = [var.m01_hosts]
    }
  }
}

#Management workload domain SSP

data "nsxt_policy_vm" "vm16" {
  display_name = var.m01_sspi_vm
}

resource "nsxt_policy_vm_tags" "vm16_tags" {
  instance_id = data.nsxt_policy_vm.vm16.id

  tag {
    scope = "m01"
    tag   = "sspi"
  }
}

resource "nsxt_policy_group" "m01_sspi" {
  nsx_id       = "M01_SSPI"
  display_name = "M01_SSPI"
  
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "m01|sspi"
    }
  }
}

resource "nsxt_policy_group" "m01_ssp" {
  nsx_id       = "M01_SSP"
  display_name = "M01_SSP"

  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Name"
      operator    = "STARTSWITH"
      value       = "m01-ssp-"
    }
  }
}

resource "nsxt_policy_group" "m01_sspm" {
  nsx_id       = "M01_SSPM"
  display_name = "M01_SSPM"
  group_type   = "IPAddress"

  tag {
    scope = "m01"
    tag   = "sspm"
  }
  
  criteria {
    ipaddress_expression {
      ip_addresses = [var.m01_sspm]
    }
  }
}

resource "nsxt_policy_group" "vcf01_m01" {
  nsx_id       = "VCF01_M01"
  display_name = "VCF01_M01"

  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "m01|"
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
      value       = "m01|"
    }
  }
  
  conjunction {
    operator = "OR"
  }

  criteria {
    path_expression {
      member_paths = [nsxt_policy_group.m01_vc.path,nsxt_policy_group.m01_ssp.path]
    }
  }
}