data "nsxt_policy_vm" "vm7" {
  display_name = var.w01_vcenter
}

data "nsxt_policy_vm" "vm8" {
  display_name = var.w01_nsx_manager_a
}

data "nsxt_policy_vm" "vm9" {
  display_name = var.w01_nsx_manager_b
}

data "nsxt_policy_vm" "vm10" {
  display_name = var.w01_nsx_manager_c
}

resource "nsxt_policy_vm_tags" "vm7_tags" {
  instance_id = data.nsxt_policy_vm.vm7.id

  tag {
    scope = "w01"
    tag   = "vc01"
  }
}

resource "nsxt_policy_vm_tags" "vm8_tags" {
  instance_id = data.nsxt_policy_vm.vm8.id

  tag {
    scope = "w01"
    tag   = "nsx01"
  }
}

resource "nsxt_policy_vm_tags" "vm9_tags" {
  instance_id = data.nsxt_policy_vm.vm9.id

  tag {
    scope = "w01"
    tag   = "nsx01"
  }
}

resource "nsxt_policy_vm_tags" "vm10_tags" {
  instance_id = data.nsxt_policy_vm.vm10.id

  tag {
    scope = "w01"
    tag   = "nsx01"
  }
}

resource "nsxt_policy_group" "w01_vc" {
  nsx_id       = "W01_VC"
  display_name = "W01_VC"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "w01|vc01"
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
}


resource "nsxt_policy_group" "w01_wld" {
  nsx_id       = "W01_WLD"
  display_name = "W01_WLD"

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
    path_expression {
      member_paths = [nsxt_policy_group.w01_hosts.path,nsxt_policy_group.w01_edges.path,nsxt_policy_group.w01_ssp.path]
    }
  }
}

resource "nsxt_policy_group" "w01_edges" {
  nsx_id       = "W01_EDGES"
  display_name = "W01_EDGES"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.w01_edges]
    }
  }
}

resource "nsxt_policy_group" "w01_hosts" {
  nsx_id       = "W01_HOSTS"
  display_name = "W01_HOSTS"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.w01_hosts]
    }
  }
}

#VI (W01_WLD) workload domain SSP

data "nsxt_policy_vm" "vm11" {
  display_name = var.w01_sspi_vm
}

data "nsxt_policy_segment" "w01_ssp_dvpg" {
  display_name = var.w01_ssp_dvpg
}

resource "nsxt_policy_vm_tags" "vm11_tags" {
  instance_id = data.nsxt_policy_vm.vm11.id

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
