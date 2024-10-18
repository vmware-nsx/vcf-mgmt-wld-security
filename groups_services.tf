data "nsxt_policy_vm" "vm1" {
  display_name = "vcf01"
}

data "nsxt_policy_vm" "vm2" {
  display_name = "m01-vc01"
}

data "nsxt_policy_vm" "vm3" {
  display_name = "m01-nsx01a"
}

data "nsxt_policy_vm" "vm4" {
  display_name = "w01-vc01"
}

data "nsxt_policy_vm" "vm5" {
  display_name = "w01-nsx01a"
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
      ip_addresses = ["172.16.11.101-172.16.11.104"]
    }
  }
}

resource "nsxt_policy_group" "w01_hosts" {
  nsx_id       = "W01_HOSTS"
  display_name = "W01_HOSTS"

  criteria {
    ipaddress_expression {
      ip_addresses = ["172.16.11.105-172.16.11.107"]
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
      ip_addresses = ["172.16.31.60"]
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
