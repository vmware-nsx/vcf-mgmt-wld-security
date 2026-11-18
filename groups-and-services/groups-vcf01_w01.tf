data "nsxt_policy_vm" "w01_vcenter" {
  display_name = var.w01.vcenter
}

data "nsxt_policy_vm" "w01_nsx_manager" {
  for_each     = toset(var.w01.nsx_managers)
  display_name = each.value
}

data "nsxt_policy_vm" "w01_avi_controller" {
  for_each     = toset(var.w01.avi_controllers)
  display_name = each.value
}

resource "nsxt_policy_vm_tags" "w01_vcenter" {
  instance_id = data.nsxt_policy_vm.w01_vcenter.id

  tag {
    scope = "w01"
    tag   = "vc01"
  }
}

resource "nsxt_policy_vm_tags" "w01_nsx_manager" {
  for_each    = data.nsxt_policy_vm.w01_nsx_manager
  instance_id = each.value.id

  tag {
    scope = "w01"
    tag   = "nsx01"
  }
}

resource "nsxt_policy_vm_tags" "w01_avi_controller" {
  for_each    = data.nsxt_policy_vm.w01_avi_controller
  instance_id = each.value.id

  tag {
    scope = "w01"
    tag   = "avi01"
  }
}

resource "nsxt_policy_group" "w01_vc" {
  nsx_id       = "W01_VC"
  display_name = "W01_VC"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Name"
      operator    = "STARTSWITH"
      value       = var.w01.vcenter
    }
  }
}

resource "nsxt_policy_group" "w01_nsx" {
  nsx_id       = "W01_NSX"
  display_name = "W01_NSX"

  # One name condition per node, OR-ed together. An empty list gives a group without criteria.
  dynamic "criteria" {
    for_each = var.w01.nsx_managers
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
    for_each = length(var.w01.nsx_managers) > 1 ? slice(var.w01.nsx_managers, 1, length(var.w01.nsx_managers)) : []
    content {
      operator = "OR"
    }
  }
}

resource "nsxt_policy_group" "w01_avi" {
  nsx_id       = "W01_AVI"
  display_name = "W01_AVI"

  # One name condition per node, OR-ed together. An empty list gives a group without criteria.
  dynamic "criteria" {
    for_each = var.w01.avi_controllers
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
    for_each = length(var.w01.avi_controllers) > 1 ? slice(var.w01.avi_controllers, 1, length(var.w01.avi_controllers)) : []
    content {
      operator = "OR"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "nsxt_policy_group" "w01_avi_se" {
  nsx_id       = "W01_AVI_SE"
  display_name = "W01_AVI_SE"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.w01.avi_se_mgmt]
    }
  }

  lifecycle {
    create_before_destroy = true
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
      ip_addresses = [var.w01.edges]
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
      ip_addresses = [var.w01.hosts]
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
      ip_addresses = [var.w01.sup01]
    }
  }
}

# Workload domain 01 SSP. Created only when var.w01.ssp is set (SSP deployed on w01).

locals {
  w01_ssp_enabled = var.w01.ssp != null
}

data "nsxt_policy_vm" "w01_sspi" {
  count        = local.w01_ssp_enabled ? 1 : 0
  display_name = var.w01.ssp.sspi_vm
}

resource "nsxt_policy_vm_tags" "w01_sspi" {
  count       = local.w01_ssp_enabled ? 1 : 0
  instance_id = data.nsxt_policy_vm.w01_sspi[0].id

  tag {
    scope = "w01"
    tag   = "sspi01"
  }
}

resource "nsxt_policy_group" "w01_sspi" {
  count        = local.w01_ssp_enabled ? 1 : 0
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
  count        = local.w01_ssp_enabled ? 1 : 0
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

resource "nsxt_policy_group" "w01_ssp_svc" {
  count        = local.w01_ssp_enabled ? 1 : 0
  nsx_id       = "W01_SSP_SVC"
  display_name = "W01_SSP_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.w01.ssp.ssp_svc]
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
      # The SSP groups are nested only once SSP is deployed on w01 (var.w01.ssp is set).
      member_paths = concat(
        [nsxt_policy_group.w01_avi.path, nsxt_policy_group.w01_avi_se.path],
        local.w01_ssp_enabled ? [nsxt_policy_group.w01_vc.path, nsxt_policy_group.w01_ssp[0].path, nsxt_policy_group.w01_ssp_svc[0].path] : []
      )
    }
  }
}


