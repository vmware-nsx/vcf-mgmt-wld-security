data "nsxt_policy_vm" "vcfops01" {
  display_name = var.fleet.vcfops01
}

data "nsxt_policy_vm" "vcf_lic" {
  display_name = var.fleet.vcf_lic
}

data "nsxt_policy_vm" "vcfops_cp" {
  display_name = var.fleet.vcfops_cp
}

data "nsxt_policy_vm" "sddc" {
  display_name = var.fleet.sddc
}

data "nsxt_policy_vm" "vcf_lhub" {
  display_name = var.fleet.vcf_lhub
}

data "nsxt_policy_vm" "sspi" {
  display_name = var.fleet.sspi
}

# VCF Operations for Networks is optional: these are created only when var.fleet.ops_net is set.
data "nsxt_policy_vm" "ops_net_platform" {
  count        = var.fleet.ops_net != null ? 1 : 0
  display_name = var.fleet.ops_net.platform
}

data "nsxt_policy_vm" "ops_net_collector" {
  count        = var.fleet.ops_net != null ? 1 : 0
  display_name = var.fleet.ops_net.collector
}

resource "nsxt_policy_vm_tags" "vcfops01" {
  instance_id = data.nsxt_policy_vm.vcfops01.id

  tag {
    scope = "vcf_fm"
    tag   = "ops"
  }
}

resource "nsxt_policy_vm_tags" "vcf_lic" {
  instance_id = data.nsxt_policy_vm.vcf_lic.id

  tag {
    scope = "vcf_fm"
    tag   = "vcf_lic"
  }
}

resource "nsxt_policy_vm_tags" "vcfops_cp" {
  instance_id = data.nsxt_policy_vm.vcfops_cp.id

  tag {
    scope = "vcf01_m"
    tag   = "ops_cp"
  }
}

resource "nsxt_policy_vm_tags" "sddc" {
  instance_id = data.nsxt_policy_vm.sddc.id

  tag {
    scope = "vcf01_m"
    tag   = "sddc"
  }
}

resource "nsxt_policy_vm_tags" "vcf_lhub" {
  instance_id = data.nsxt_policy_vm.vcf_lhub.id

  tag {
    scope = "vcf_fm"
    tag   = "vcf_lhub"
  }
}

resource "nsxt_policy_vm_tags" "sspi" {
  instance_id = data.nsxt_policy_vm.sspi.id

  tag {
    scope = "vcf_fm"
    tag   = "sspi"
  }
}

resource "nsxt_policy_vm_tags" "ops_net_platform" {
  count       = var.fleet.ops_net != null ? 1 : 0
  instance_id = data.nsxt_policy_vm.ops_net_platform[0].id

  tag {
    scope = "vcf_fm"
    tag   = "ops_net"
  }
}

resource "nsxt_policy_vm_tags" "ops_net_collector" {
  count       = var.fleet.ops_net != null ? 1 : 0
  instance_id = data.nsxt_policy_vm.ops_net_collector[0].id

  tag {
    scope = "vcf01_m"
    tag   = "ops_net_cn"
  }
}

resource "nsxt_policy_group" "vcf_ops" {
  nsx_id       = "VCF_OPS"
  display_name = "VCF_OPS"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "vcf_fm|ops"
    }
  }
}

resource "nsxt_policy_group" "vcf01_ops_cp" {
  nsx_id       = "VCF01_OPS_CP"
  display_name = "VCF01_OPS_CP"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "vcf01_m|ops_cp"
    }
  }
}

resource "nsxt_policy_group" "vcf_lic" {
  nsx_id       = "VCF_LIC"
  display_name = "VCF_LIC"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "vcf_fm|vcf_lic"
    }
  }
}

resource "nsxt_policy_group" "vcf_lhub" {
  nsx_id       = "VCF_LHUB"
  display_name = "VCF_LHUB"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "vcf_fm|vcf_lhub"
    }
  }

  conjunction {
    operator = "OR"
  }

  criteria {
    ipaddress_expression {
      ip_addresses = [var.fleet.vcf_lhub_ip]
    }
  }
}

resource "nsxt_policy_group" "vcf_ops_net" {
  nsx_id       = "VCF_OPS_NET"
  display_name = "VCF_OPS_NET"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "vcf_fm|ops_net"
    }
  }
}

resource "nsxt_policy_group" "vcf01_ops_net_cn" {
  nsx_id       = "VCF01_OPS_NET_CN"
  display_name = "VCF01_OPS_NET_CN"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "vcf01_m|ops_net_cn"
    }
  }
}

resource "nsxt_policy_group" "vcf01_msvc" {
  nsx_id       = "VCF01_MSVC"
  display_name = "VCF01_MSVC"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Name"
      operator    = "STARTSWITH"
      value       = var.fleet.vcfmsvc
    }
  }
}

resource "nsxt_policy_group" "vcf_a" {
  nsx_id       = "VCF_A"
  display_name = "VCF_A"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Name"
      operator    = "STARTSWITH"
      value       = var.fleet.vcfa
    }
  }
}

resource "nsxt_policy_group" "vcf01_sddc" {
  nsx_id       = "VCF01_SDDC"
  display_name = "VCF01_SDDC"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "vcf01_m|sddc"
    }
  }
}

resource "nsxt_policy_group" "vcf_a_lb" {
  nsx_id       = "VCF_A_LB"
  display_name = "VCF_A_LB"
  group_type   = "IPAddress"
  criteria {
    ipaddress_expression {
      ip_addresses = [var.fleet.vcfa_vip]
    }
  }
}

resource "nsxt_policy_group" "vcf01_sspi" {
  nsx_id       = "VCF01_SSPI"
  display_name = "VCF01_SSPI"

  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "vcf_fm|sspi"
    }
  }
}

resource "nsxt_policy_group" "vcf_fm" {
  nsx_id       = "VCF_FM"
  display_name = "VCF_FM"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "vcf_fm|"
    }
  }

  conjunction {
    operator = "OR"
  }

  criteria {
    path_expression {
      member_paths = [nsxt_policy_group.vcf_a.path]
    }
  }

  conjunction {
    operator = "OR"
  }

  criteria {
    path_expression {
      member_paths = [nsxt_policy_group.vcf01_msvc.path]
    }
  }

  conjunction {
    operator = "OR"
  }

  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "vcf01_m|"
    }
  }

  conjunction {
    operator = "OR"
  }

  criteria {
    path_expression {
      member_paths = [nsxt_policy_group.vcf01_sspi.path]
    }
  }
}

resource "nsxt_policy_group" "vcf_fleet" {
  nsx_id       = "VCF_FLEET"
  display_name = "VCF_FLEET"

  criteria {
    path_expression {
      member_paths = [nsxt_policy_group.vcf_fm.path, nsxt_policy_group.vcf01_m01.path, nsxt_policy_group.vcf01_w01.path]
    }
  }
}
