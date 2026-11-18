# Application category policies for workload domain 01 (w01): vCenter, NSX Manager, Avi and, when
# var.ssp_enabled is set, SSP. Policy sequence numbers 11-14 (fm uses 1-7, m01 uses 8-10).

resource "nsxt_policy_security_policy" "w01_vc_policy" {
  display_name    = "Workload Domain vCenter Server"
  description     = "Workload Domain 01 vCenter Policy"
  category        = "Application"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["w01_vc"]]
  sequence_number = 11

  rule {
    display_name       = "vCenter (In)"
    source_groups      = [var.group_paths["w01_hosts"], var.group_paths["w01_nsx"], var.group_paths["w01_sup01"]]
    destination_groups = [var.group_paths["w01_vc"]]
    services           = [var.service_paths["https"], var.service_paths["tcp_6501_6502"], var.service_paths["tcp_7475_7476"], var.service_paths["tcp_9084"], var.service_paths["tcp_6500"], var.service_paths["tcp_9087"], var.service_paths["udp_902"], var.service_paths["http"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "vCenter (Out)"
    source_groups      = [var.group_paths["w01_vc"]]
    destination_groups = [var.group_paths["w01_hosts"], var.group_paths["w01_nsx"], var.group_paths["w01_sup01"]]
    services           = [var.service_paths["icmp_all"], var.service_paths["tcp_1443"], var.service_paths["update_manager"], var.service_paths["https"], var.service_paths["ssh"], var.service_paths["tcp_6443"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name = "vCenter (Lock Down)"
    scope        = [var.group_paths["w01_vc"]]
    action       = "DROP"
    ip_version   = "IPV4"
    logged       = true
    log_label    = "w01_vc"
  }
}

resource "nsxt_policy_security_policy" "w01_nsx_policy" {
  display_name    = "Workload Domain NSX Manager"
  description     = "Workload Domain 01 NSX Policy"
  category        = "Application"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["w01_nsx"]]
  sequence_number = 12

  rule {
    display_name       = "NSX Manager (Intra)"
    source_groups      = [var.group_paths["w01_nsx"]]
    destination_groups = [var.group_paths["w01_nsx"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name       = "NSX Manager (In)"
    source_groups      = [var.group_paths["w01_vc"], var.group_paths["w01_sup01"]]
    destination_groups = [var.group_paths["w01_nsx"]]
    services           = [var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "NSX Manager (Out)"
    source_groups      = [var.group_paths["w01_hosts"], var.group_paths["w01_edges"], var.group_paths["w01_nsx"]]
    destination_groups = [var.group_paths["w01_hosts"], var.group_paths["w01_edges"], var.group_paths["w01_nsx"], var.group_paths["w01_vc"]]
    services           = [var.service_paths["tcp_5671"], var.service_paths["tcp_1234_1235"], var.service_paths["http"], var.service_paths["https"], var.service_paths["tcp_9087"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name = "NSX Manager (Lock Down)"
    action       = "DROP"
    ip_version   = "IPV4"
    logged       = true
    log_label    = "w01_nsx"
  }
}

# Workload Domain 01 SSP Policy.
#
# Created only when SSP is deployed on workload domain 01, that is, when var.w01.ssp is set in the
# root module. Until then the w01_sspi, w01_ssp and w01_ssp_svc groups do not exist (they are not
# in group_paths) and this policy is skipped.
resource "nsxt_policy_security_policy" "w01_ssp_policy" {
  count = var.ssp_enabled ? 1 : 0

  display_name    = "Workload Domain 01 SSP Policy"
  description     = "Workload Domain 01 SSP Policy"
  category        = "Application"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["w01_sspi"], var.group_paths["w01_ssp"]]
  sequence_number = 14

  rule {
    display_name       = "SSPI and SSPs to vCenter"
    source_groups      = [var.group_paths["w01_sspi"], var.group_paths["w01_ssp"]]
    destination_groups = [var.group_paths["w01_vc"]]
    services           = [var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name       = "SSP to NSX Manager"
    source_groups      = [var.group_paths["w01_ssp"]]
    destination_groups = [var.group_paths["w01_nsx"]]
    services           = [var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name       = "SSPI to SSP"
    source_groups      = [var.group_paths["w01_sspi"]]
    destination_groups = [var.group_paths["w01_ssp"]]
    services           = [var.service_paths["tcp_6443"], var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name       = "SSP to SSPI Registry"
    source_groups      = [var.group_paths["w01_ssp"]]
    destination_groups = [var.group_paths["w01_sspi"]]
    services           = [var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name       = "SSP Ingestion"
    source_groups      = [var.group_paths["w01_nsx"], var.group_paths["w01_hosts"], var.group_paths["w01_edges"]]
    destination_groups = [var.group_paths["w01_ssp_svc"]]
    services           = [var.service_paths["https"], var.service_paths["tcp_9092"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name  = "SSP Feeds"
    source_groups = [var.group_paths["w01_ssp"]]
    services      = [var.service_paths["https"]]
    action        = "ALLOW"
    ip_version    = "IPV4"
    logged        = false
  }

  rule {
    display_name       = "SSP Internal"
    source_groups      = [var.group_paths["w01_ssp"]]
    destination_groups = [var.group_paths["w01_ssp"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name = "Workload Domain 01 SSP Lock Down"
    action       = "DROP"
    ip_version   = "IPV4"
    logged       = true
    log_label    = "w01_ssp"
  }
}
