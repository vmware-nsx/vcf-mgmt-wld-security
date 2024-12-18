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
  display_name = var.w01_vcenter
}

data "nsxt_policy_vm" "vm5" {
  display_name = var.w01_nsx_manager_a
}

data "nsxt_policy_service" "icmp_all" {
  display_name = var.icmp_all
}

data "nsxt_policy_service" "dns_tcp" {
  display_name = var.dns_tcp
}

data "nsxt_policy_service" "activdir" {
  display_name = var.activdir
}

data "nsxt_policy_service" "dns_udp" {
  display_name = var.dns_udp
}

data "nsxt_policy_service" "https" {
  display_name = var.https
}

data "nsxt_policy_service" "http" {
  display_name = var.http
}

data "nsxt_policy_service" "ldap" {
  display_name = var.ldap
}

data "nsxt_policy_service" "ldaps" {
  display_name = var.ldaps
}

data "nsxt_policy_service" "ssh" {
  display_name = var.ssh
}

data "nsxt_policy_service" "syslog_udp" {
  display_name = var.syslog_udp
}

data "nsxt_policy_service" "ntp" {
  display_name = var.ntp
}

data "nsxt_policy_service" "rdp" {
  display_name = var.rdp
}

data "nsxt_policy_service" "update_manager" {
  display_name = var.update_manager
}

#data "nsxt_policy_service" "tcp_902" {
#  display_name = var.tcp_902
#}

data "nsxt_policy_service" "udp_902" {
  display_name = var.udp_902
}

#data "nsxt_policy_service" "tcp_9000_9100" {
#  display_name = var.tcp_9000_9100
#}

data "nsxt_policy_service" "tcp_9087" {
  display_name = var.tcp_9087
}

data "nsxt_policy_service" "tcp_9084" {
  display_name = var.tcp_9084
}

data "nsxt_policy_context_profile" "cxt_activdir" {
  display_name = var.cxt_activdir
}

data "nsxt_policy_context_profile" "cxt_ldap" {
  display_name = var.cxt_ldap
}

data "nsxt_policy_context_profile" "cxt_dns" {
  display_name = var.cxt_dns
}

data "nsxt_policy_context_profile" "cxt_ssl" {
  display_name = var.cxt_ssl
}

data "nsxt_policy_context_profile" "cxt_dcerpc" {
  display_name = var.cxt_dcerpc
}

resource "nsxt_policy_vm_tags" "vm1_tags" {
  instance_id = data.nsxt_policy_vm.vm1.id

  tag {
    scope = "m01"
    tag   = "vcf01"
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
    scope = "w01"
    tag   = "vc01"
  }
}

resource "nsxt_policy_vm_tags" "vm5_tags" {
  instance_id = data.nsxt_policy_vm.vm5.id

  tag {
    scope = "w01"
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
      value       = "m01|vcf01"
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
}

resource "nsxt_policy_group" "m01_edges" {
  nsx_id       = "M01_EDGES"
  display_name = "M01_EDGES"

  criteria {
    ipaddress_expression {
      ip_addresses = ["172.16.10.61-172.16.10.64"]
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

resource "nsxt_policy_group" "m01_hosts" {
  nsx_id       = "M01_HOSTS"
  display_name = "M01_HOSTS"

  criteria {
    ipaddress_expression {
      ip_addresses = ["172.16.11.11-172.16.11.14"]
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

resource "nsxt_policy_group" "infra_svc" {
  nsx_id       = "INFRA_SVC"
  display_name = "INFRA_SVC"

  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.10", "192.168.110.1"]
    }
  }
}

resource "nsxt_policy_group" "bastion" {
  nsx_id       = "BASTION"
  display_name = "BASTION"

  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.10"]
    }
  }
}

resource "nsxt_policy_group" "tools" {
  nsx_id       = "TOOLS"
  display_name = "TOOLS"

  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.11"]
    }
  }
}

resource "nsxt_policy_group" "w01_nfs" {
  nsx_id       = "W01_NFS"
  display_name = "W01_NFS"

  criteria {
    ipaddress_expression {
      ip_addresses = ["172.16.30.60"]
    }
  }
}

resource "nsxt_policy_group" "backup_server" {
  nsx_id       = "BACKUP_SERVER"
  display_name = "BACKUP_SERVER"

  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.11"]
    }
  }
}

resource "nsxt_policy_service" "tcp-elm" {
  description  = "ELM ports service provisioned by Terraform"
  display_name = "TCP-VC-ELM"

  l4_port_set_entry {
    display_name      = "vc-elm"
    protocol          = "TCP"
    destination_ports = ["2012", "2020"]
  }
  
    l4_port_set_entry {
    display_name      = "vc-elm-source"
    protocol          = "TCP"
    source_ports = ["443"]
  }
}

resource "nsxt_policy_service" "tcp-5480" {
  description  = "Workload Domain Deployment"
  display_name = "TCP-5480"

  l4_port_set_entry {
    display_name      = "tcp-5480"
    protocol          = "TCP"
    destination_ports = ["5480"]
  }
}
