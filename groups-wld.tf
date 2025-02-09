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
      member_paths = [nsxt_policy_group.w01_hosts.path,nsxt_policy_group.w01_edges.path]
    }
  }
}

resource "nsxt_policy_group" "w01_edges" {
  nsx_id       = "W01_EDGES"
  display_name = "W01_EDGES"

  criteria {
    ipaddress_expression {
      ip_addresses = ["172.16.10.65-172.16.10.68"]
    }
  }
}

resource "nsxt_policy_group" "w01_hosts" {
  nsx_id       = "W01_HOSTS"
  display_name = "W01_HOSTS"

  criteria {
    ipaddress_expression {
      ip_addresses = ["172.16.11.15-172.16.11.17"]
    }
  }
}
