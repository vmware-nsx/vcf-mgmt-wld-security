data "nsxt_policy_vm" "vm1" {
  display_name = var.vcfops01
}

data "nsxt_policy_vm" "vm2" {
  display_name = var.vcfopslcm
}

data "nsxt_policy_vm" "vm3" {
  display_name = var.vcfops_logs
}

data "nsxt_policy_vm" "vm4" {
  display_name = var.vcfops_net
}

data "nsxt_policy_vm" "vm6" {
  display_name = var.vcfops_cp
}

data "nsxt_policy_vm" "vm7" {
  display_name = var.vcfops_net_cn
}

data "nsxt_policy_vm" "vm8" {
  display_name = var.sddc
}

resource "nsxt_policy_vm_tags" "vm1_tags" {
  instance_id = data.nsxt_policy_vm.vm1.id

  tag {
    scope = "vcf_fm"
    tag   = "ops"
  }
}

resource "nsxt_policy_vm_tags" "vm2_tags" {
  instance_id = data.nsxt_policy_vm.vm2.id

  tag {
    scope = "vcf_fm"
    tag   = "ops_fm"
  }
}

resource "nsxt_policy_vm_tags" "vm3_tags" {
  instance_id = data.nsxt_policy_vm.vm3.id

  tag {
    scope = "vcf_fm"
    tag   = "ops_log"
  }
}

resource "nsxt_policy_vm_tags" "vm4_tags" {
  instance_id = data.nsxt_policy_vm.vm4.id

  tag {
    scope = "vcf_fm"
    tag   = "ops_net"
  }
}

resource "nsxt_policy_vm_tags" "vm6_tags" {
  instance_id = data.nsxt_policy_vm.vm6.id

  tag {
    scope = "vcf01_m"
    tag   = "ops_cp"
  }
}

resource "nsxt_policy_vm_tags" "vm7_tags" {
  instance_id = data.nsxt_policy_vm.vm7.id

  tag {
    scope = "vcf01_m"
    tag   = "ops_net_cn"
  }
}

resource "nsxt_policy_vm_tags" "vm8_tags" {
  instance_id = data.nsxt_policy_vm.vm8.id

  tag {
    scope = "vcf01_m"
    tag   = "sddc"
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

resource "nsxt_policy_group" "vcf_ops_fm" {
  nsx_id       = "VCF_OPS_FM"
  display_name = "VCF_OPS_FM"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "vcf_fm|ops_fm"
    }
  }
}

resource "nsxt_policy_group" "vcf_ops_logs" {
  nsx_id       = "VCF_OPS_LOGS"
  display_name = "VCF_OPS_LOGS"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "vcf_fm|ops_log"
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

resource "nsxt_policy_group" "vcf_a" {
  nsx_id       = "VCF_A"
  display_name = "VCF_A"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Name"
      operator    = "STARTSWITH"
      value       = var.vcfa01
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
  criteria {
    ipaddress_expression {
      ip_addresses = ["172.16.10.26"]
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
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "vcf01_m|"
    }
  }
}

resource "nsxt_policy_group" "vcf_f" {
  nsx_id       = "VCF_FLEET"
  display_name = "VCF_FLEET"

  criteria {
    path_expression {
      member_paths = [nsxt_policy_group.vcf_fm.path,nsxt_policy_group.vcf01_m01.path,nsxt_policy_group.vcf01_w01.path]
    }
  }
}