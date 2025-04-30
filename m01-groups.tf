data "nsxt_policy_vm" "vm1" {
  display_name = var.sddc_manager
}

data "nsxt_policy_vm" "vm2" {
  display_name = var.m01_vcenter
}

data "nsxt_policy_vm" "vm3" {
  display_name = var.m01_nsx_manager_a
}

data "nsxt_policy_vm" "vm4" {
  display_name = var.m01_nsx_manager_b
}

data "nsxt_policy_vm" "vm5" {
  display_name = var.m01_nsx_manager_c
}

data "nsxt_policy_segment" "vm_management_dvpg" {
  display_name = var.vm_management_dvpg
}

resource "nsxt_policy_vm_tags" "vm1_tags" {
  instance_id = data.nsxt_policy_vm.vm1.id

  tag {
    scope = "m01"
    tag   = "sddc"
  }
}

resource "nsxt_policy_vm_tags" "vm2_tags" {
  instance_id = data.nsxt_policy_vm.vm2.id

  tag {
    scope = "m01"
    tag   = "vc01"
  }
}

resource "nsxt_policy_vm_tags" "vm3_tags" {
  instance_id = data.nsxt_policy_vm.vm3.id

  tag {
    scope = "m01"
    tag   = "nsx01"
  }
}

resource "nsxt_policy_vm_tags" "vm4_tags" {
  instance_id = data.nsxt_policy_vm.vm4.id

  tag {
    scope = "m01"
    tag   = "nsx01"
  }
}

resource "nsxt_policy_vm_tags" "vm5_tags" {
  instance_id = data.nsxt_policy_vm.vm5.id

  tag {
    scope = "m01"
    tag   = "nsx01"
  }
}

resource "nsxt_policy_group" "sddc_mgr" {
  nsx_id       = "SDDC_MGR"
  display_name = "SDDC_MGR"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "m01|sddc"
    }
  }
}

resource "nsxt_policy_group" "m01_vc" {
  nsx_id       = "M01_VC"
  display_name = "M01_VC"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Tag"
      operator    = "EQUALS"
      value       = "m01|vc01"
    }
  }
}

resource "nsxt_policy_group" "elm_vc" {
  nsx_id       = "ELM_VC"
  display_name = "ELM_VC"
  criteria {
    condition {
      member_type = "VirtualMachine"
      key         = "Name"
      operator    = "CONTAINS"
      value       = "vc01"
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
}

resource "nsxt_policy_group" "m01_wld" {
  nsx_id       = "M01_WLD"
  display_name = "M01_WLD"

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
    path_expression {
      member_paths = [nsxt_policy_group.m01_hosts.path,nsxt_policy_group.m01_edges.path,nsxt_policy_group.m01_ssp.path]
    }
  }
}

resource "nsxt_policy_group" "vcf01_mgmt" {
  nsx_id       = "VCF01_MGMT"
  display_name = "VCF01_MGMT"

  criteria {
    path_expression {
      member_paths = [data.nsxt_policy_segment.vm_management_dvpg.path]
    }
  }
}

resource "nsxt_policy_group" "vcf01" {
  nsx_id       = "VCF01"
  display_name = "VCF01"

  criteria {
    path_expression {
      member_paths = [nsxt_policy_group.vcf01_mgmt.path,nsxt_policy_group.aria_suite.path,nsxt_policy_group.vcf01_ssp.path]
    }
  }
}

resource "nsxt_policy_group" "m01_edges" {
  nsx_id       = "M01_EDGES"
  display_name = "M01_EDGES"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = ["172.16.10.61-172.16.10.64"]
    }
  }
}

resource "nsxt_policy_group" "m01_hosts" {
  nsx_id       = "M01_HOSTS"
  display_name = "M01_HOSTS"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = ["172.16.11.11-172.16.11.14"]
    }
  }
}

resource "nsxt_policy_group" "dns_svc" {
  nsx_id       = "DNS_SVC"
  display_name = "DNS_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.10"]
    }
  }
}

resource "nsxt_policy_group" "ntp_svc" {
  nsx_id       = "NTP_SVC"
  display_name = "NTP_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.1"]
    }
  }
}

resource "nsxt_policy_group" "dhcp_svc" {
  nsx_id       = "DHCP_SVC"
  display_name = "DHCP_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.10"]
    }
  }
}

resource "nsxt_policy_group" "ad_svc" {
  nsx_id       = "AD_SVC"
  display_name = "AD_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.10"]
    }
  }
}

resource "nsxt_policy_group" "smtp_svc" {
  nsx_id       = "SMTP_SVC"
  display_name = "SMTP_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.1"]
    }
  }
}

resource "nsxt_policy_group" "bastion" {
  nsx_id       = "BASTION"
  display_name = "BASTION"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.10"]
    }
  }
}

resource "nsxt_policy_group" "tools" {
  nsx_id       = "TOOLS"
  display_name = "TOOLS"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.11"]
    }
  }
}

resource "nsxt_policy_group" "backup_server" {
  nsx_id       = "BACKUP_SERVER"
  display_name = "BACKUP_SERVER"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.11"]
    }
  }
}

#Management workload domain SSP

data "nsxt_policy_vm" "vm6" {
  display_name = var.m01_sspi_vm
}

data "nsxt_policy_segment" "m01_ssp_dvpg" {
  display_name = var.m01_ssp_dvpg
}

resource "nsxt_policy_vm_tags" "vm6_tags" {
  instance_id = data.nsxt_policy_vm.vm6.id

  tag {
    scope = "m01"
    tag   = "sspi01"
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
      value       = "m01|sspi01"
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

  criteria {
    ipaddress_expression {
      ip_addresses = ["172.16.40.11-172.16.40.32"]
    }
  }
}

resource "nsxt_policy_group" "vcf01_ssp" {
  nsx_id       = "VCF01_SSP"
  display_name = "VCF01_SSP"

  criteria {
    path_expression {
      member_paths = [data.nsxt_policy_segment.m01_ssp_dvpg.path]
    }
  }
}

resource "nsxt_policy_group" "siem_svc" {
  nsx_id       = "SIEM_SVC"
  display_name = "SIEM_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.12"]
    }
  }
}