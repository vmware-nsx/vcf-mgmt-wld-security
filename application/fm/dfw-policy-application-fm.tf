# Application category policies for the VCF Fleet Management components.
# Policy sequence numbers 1-7 (m01 uses 8-10, w01 uses 11-14); keep the ranges apart so the policies
# from the three application modules never collide.

resource "nsxt_policy_security_policy" "vcfops_policy" {
  display_name    = "VCF Operations"
  description     = "VCF Operations Policy"
  category        = "Application"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["vcf01_ops_cp"], var.group_paths["vcf_ops"]]
  sequence_number = 1

  rule {
    display_name       = "VCF Operations (Intra)"
    source_groups      = [var.group_paths["vcf01_ops_cp"], var.group_paths["vcf_ops"]]
    destination_groups = [var.group_paths["vcf01_ops_cp"], var.group_paths["vcf_ops"]]
    action             = "ALLOW"
    ip_version         = "IPV4_IPV6"
    logged             = false
  }

  rule {
    display_name       = "VCF Operations (In)"
    source_groups      = [var.group_paths["vcf01_msvc"], var.group_paths["vcf_lic"]]
    destination_groups = [var.group_paths["vcf_ops"]]
    services           = [var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "VCF Operations (Out)"
    source_groups      = [var.group_paths["vcf01_ops_cp"], var.group_paths["vcf_ops"]]
    destination_groups = [var.group_paths["vcf_a"], var.group_paths["vcf_ops_net"], var.group_paths["vcf01_msvc"], var.group_paths["vcf01_sddc"]]
    services           = [var.service_paths["https"], var.service_paths["tcp_4505_4506"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name = "VCF Operations (Lock Down)"
    action       = "DROP"
    ip_version   = "IPV4"
    logged       = true
    log_label    = "vcf_ops"
  }
}

resource "nsxt_policy_security_policy" "vcfa_policy" {
  display_name    = "VCF Automation"
  description     = "VCF Automation Policy"
  category        = "Application"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["vcf_a"]]
  sequence_number = 2

  rule {
    display_name       = "VCF Automation (Intra)"
    source_groups      = [var.group_paths["vcf_a"]]
    destination_groups = [var.group_paths["vcf_a"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name       = "VCF Automation (In)"
    source_groups      = [var.group_paths["w01_sup01"], var.group_paths["vcf01_ops_cp"], var.group_paths["vcf01_msvc"], var.group_paths["vcf01_sddc"], var.group_paths["vcf_ops"]]
    destination_groups = [var.group_paths["vcf_a"]]
    services           = [var.service_paths["tcp_6443"], var.service_paths["https"], var.service_paths["ssh"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "VCF Automation (Out)"
    source_groups      = [var.group_paths["vcf_a"]]
    destination_groups = [var.group_paths["vcf01_sddc"]]
    services           = [var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name = "VCF Automation (Lock Down)"
    action       = "DROP"
    ip_version   = "IPV4"
    logged       = true
    log_label    = "vcfa"
  }
}

resource "nsxt_policy_security_policy" "vcfops_net_policy" {
  display_name    = "VCF Operations for Networks"
  description     = "VCF Operations for Networks Policy"
  category        = "Application"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["vcf01_ops_net_cn"], var.group_paths["vcf_ops_net"]]
  sequence_number = 3

  rule {
    display_name       = "VCF Operations for Networks (Intra)"
    source_groups      = [var.group_paths["vcf_ops_net"], var.group_paths["vcf01_ops_net_cn"]]
    destination_groups = [var.group_paths["vcf01_ops_net_cn"], var.group_paths["vcf_ops_net"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name       = "VCF Operations for Networks (In)"
    source_groups      = [var.group_paths["vcf_ops"]]
    destination_groups = [var.group_paths["vcf_ops_net"]]
    services           = [var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name  = "VCF Operations for Networks (Out)"
    source_groups = [var.group_paths["vcf01_ops_net_cn"]]
    action        = "ALLOW"
    ip_version    = "IPV4"
    direction     = "OUT"
    logged        = false
  }

  rule {
    display_name = "VCF Operations for Networks (Lock Down)"
    action       = "DROP"
    ip_version   = "IPV4"
    logged       = true
    log_label    = "vcf_ops_net"
  }
}

resource "nsxt_policy_security_policy" "vcf_msvc_policy" {
  display_name    = "VCF Management Services"
  description     = "VCF Management Services (VCF01_MSVC) Policy"
  category        = "Application"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["vcf01_msvc"]]
  sequence_number = 4

  rule {
    display_name       = "VCF Management Service (Intra)"
    source_groups      = [var.group_paths["vcf01_msvc"]]
    destination_groups = [var.group_paths["vcf01_msvc"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name       = "VCF Management Service (In)"
    source_groups      = [var.group_paths["vcf01_ops_cp"], var.group_paths["vcf01_sddc"], var.group_paths["vcf_ops"]]
    destination_groups = [var.group_paths["vcf01_msvc"]]
    services           = [var.service_paths["https"], var.service_paths["tcp_4505_4506"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "VCF Management Service (Out)"
    source_groups      = [var.group_paths["vcf01_msvc"]]
    destination_groups = [var.group_paths["vcf01_sddc"], var.group_paths["vcf_ops"], var.group_paths["vcf_a"]]
    services           = [var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name = "VCF Management Services (Lock Down)"
    action       = "DROP"
    ip_version   = "IPV4"
    logged       = true
    log_label    = "vcf01_msvc"
  }
}

resource "nsxt_policy_security_policy" "vcf_lic_policy" {
  display_name    = "VCF License Server"
  description     = "VCF License (VCF_LIC) Policy"
  category        = "Application"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["vcf_lic"]]
  sequence_number = 5

  rule {
    display_name       = "VCF License Server (Out)"
    source_groups      = [var.group_paths["vcf_lic"]]
    destination_groups = [var.group_paths["vcf_ops"]]
    services           = [var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name = "VCF License (Lock Down)"
    action       = "DROP"
    ip_version   = "IPV4"
    logged       = true
    log_label    = "vcf_lic"
  }
}

resource "nsxt_policy_security_policy" "vcf_lhub_policy" {
  display_name    = "vDefend License Hub"
  description     = "vDefend License Hub (VCF_LHUB) Policy"
  category        = "Application"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["vcf_lhub"]]
  sequence_number = 6

  rule {
    display_name = "vDefend License Hub (Lock Down)"
    action       = "DROP"
    ip_version   = "IPV4"
    logged       = true
    log_label    = "vcf_lhub"
  }
}

resource "nsxt_policy_security_policy" "vcf_sddc_policy" {
  display_name    = "SDDC Manager"
  description     = "VCF SDDC Manager (VCF01_SDDC) Policy"
  category        = "Application"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["vcf01_sddc"]]
  sequence_number = 7

  rule {
    display_name       = "SDDC Manager (in)"
    source_groups      = [var.group_paths["vcf01_ops_cp"], var.group_paths["vcf01_msvc"], var.group_paths["vcf_ops"]]
    destination_groups = [var.group_paths["vcf01_sddc"]]
    services           = [var.service_paths["https"], var.service_paths["icmp_echo"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "SDDC Manager (Out)"
    source_groups      = [var.group_paths["vcf01_sddc"]]
    destination_groups = [var.group_paths["vcf_a"], var.group_paths["vcf01_ops_cp"], var.group_paths["vcf01_msvc"], var.group_paths["vcf_ops"]]
    services           = [var.service_paths["https"], var.service_paths["tcp_4505_4506"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name = "SDDC Manager (Lock Down)"
    action       = "DROP"
    ip_version   = "IPV4"
    logged       = true
    log_label    = "vcf01_sddc"
  }
}
