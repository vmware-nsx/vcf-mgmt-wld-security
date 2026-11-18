data "nsxt_policy_vm" "m01_vcenter" {
  display_name = var.m01.vcenter
}

data "nsxt_policy_vm" "m01_nsx_manager" {
  for_each     = toset(var.m01.nsx_managers)
  display_name = each.value
}

data "nsxt_policy_vm" "m01_avi_controller" {
  for_each     = toset(var.m01.avi_controllers)
  display_name = each.value
}

resource "nsxt_policy_vm_tags" "m01_vcenter" {
  instance_id = data.nsxt_policy_vm.m01_vcenter.id

  tag {
    scope = "m01"
    tag   = "vc01"
  }
}

resource "nsxt_policy_vm_tags" "m01_nsx_manager" {
  for_each    = data.nsxt_policy_vm.m01_nsx_manager
  instance_id = each.value.id

  tag {
    scope = "m01"
    tag   = "nsx01"
  }
}

resource "nsxt_policy_vm_tags" "m01_avi_controller" {
  for_each    = data.nsxt_policy_vm.m01_avi_controller
  instance_id = each.value.id

  tag {
    scope = "m01"
    tag   = "avi01"
  }
}

resource "nsxt_policy_group" "m01_vc" {
  nsx_id       = "M01_VC"
  display_name = "M01_VC"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Name"
      operator    = "STARTSWITH"
      value       = var.m01.vcenter
    }
  }
}

resource "nsxt_policy_group" "m01_nsx" {
  nsx_id       = "M01_NSX"
  display_name = "M01_NSX"

  # One name condition per node, OR-ed together. An empty list gives a group without criteria.
  dynamic "criteria" {
    for_each = var.m01.nsx_managers
    content {
      condition {
        member_type = "VirtualMachine"
        key         = "Name"
        operator    = "STARTSWITH"
        value       = criteria.value
      }
    }
  }

  dynamic "conjunction" {
    for_each = length(var.m01.nsx_managers) > 1 ? slice(var.m01.nsx_managers, 1, length(var.m01.nsx_managers)) : []
    content {
      operator = "OR"
    }
  }
}

resource "nsxt_policy_group" "m01_avi" {
  nsx_id       = "M01_AVI"
  display_name = "M01_AVI"

  # One name condition per node, OR-ed together. An empty list gives a group without criteria.
  dynamic "criteria" {
    for_each = var.m01.avi_controllers
    content {
      condition {
        member_type = "VirtualMachine"
        key         = "Name"
        operator    = "STARTSWITH"
        value       = criteria.value
      }
    }
  }

  dynamic "conjunction" {
    for_each = length(var.m01.avi_controllers) > 1 ? slice(var.m01.avi_controllers, 1, length(var.m01.avi_controllers)) : []
    content {
      operator = "OR"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "nsxt_policy_group" "m01_avi_se" {
  nsx_id       = "M01_AVI_SE"
  display_name = "M01_AVI_SE"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.m01.avi_se_mgmt]
    }
  }

  lifecycle {
    create_before_destroy = true
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
      ip_addresses = [var.m01.edges]
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
      ip_addresses = [var.m01.hosts]
    }
  }
}

#Management workload domain SSP

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

resource "nsxt_policy_group" "m01_ssp_svc" {
  nsx_id       = "M01_SSP_SVC"
  display_name = "M01_SSP_SVC"
  group_type   = "IPAddress"

  tag {
    scope = "m01"
    tag   = "ssp_svc"
  }

  criteria {
    ipaddress_expression {
      ip_addresses = [var.m01.ssp_svc]
    }
  }

  lifecycle {
    create_before_destroy = true
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
      member_paths = [nsxt_policy_group.m01_vc.path, nsxt_policy_group.m01_ssp.path, nsxt_policy_group.m01_avi.path, nsxt_policy_group.m01_avi_se.path]
    }
  }
}