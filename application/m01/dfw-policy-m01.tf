# Application category policies for the management domain (m01): vCenter, Avi and SSP.
# Policy sequence numbers 8-10 (fm uses 1-7, w01 uses 11-14).

resource "nsxt_policy_security_policy" "m01_vc_policy" {
  display_name    = "Management Domain vCenter Server"
  description     = "Management Domain vCenter Policy"
  category        = "Application"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["m01_vc"]]
  sequence_number = 8

  rule {
    display_name       = "vCenter (In)"
    source_groups      = [var.group_paths["m01_avi"], var.group_paths["m01_hosts"], var.group_paths["m01_nsx"], var.group_paths["m01_ssp"]]
    destination_groups = [var.group_paths["m01_vc"]]
    services           = [var.service_paths["https"], var.service_paths["tcp_6501_6502"], var.service_paths["tcp_7475_7476"], var.service_paths["tcp_9084"], var.service_paths["tcp_6500"], var.service_paths["tcp_9087"], var.service_paths["udp_902"], var.service_paths["http"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "vCenter (Out)"
    source_groups      = [var.group_paths["m01_vc"]]
    destination_groups = [var.group_paths["m01_hosts"], var.group_paths["m01_nsx"]]
    services           = [var.service_paths["icmp_all"], var.service_paths["tcp_1443"], var.service_paths["update_manager"], var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name = "vCenter (Lock Down)"
    scope        = [var.group_paths["m01_vc"]]
    action       = "DROP"
    ip_version   = "IPV4"
    logged       = true
    log_label    = "m01_vc"
  }
}

resource "nsxt_policy_security_policy" "m01_avi_policy" {
  display_name    = "Management Domain Avi Controller"
  description     = "Management Domain Avi Policy"
  category        = "Application"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["m01_avi"]]
  sequence_number = 9

  rule {
    display_name       = "Avi Controller (Intra)"
    source_groups      = [var.group_paths["m01_avi"]]
    destination_groups = [var.group_paths["m01_avi"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name       = "Avi Controller (In)"
    source_groups      = [var.group_paths["m01_nsx"], var.group_paths["m01_avi_se"]]
    destination_groups = [var.group_paths["m01_avi"]]
    services           = [var.service_paths["https"], var.service_paths["ssh"], var.service_paths["tcp_8443"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "Avi Controller (Out)"
    source_groups      = [var.group_paths["m01_avi"]]
    destination_groups = [var.group_paths["m01_nsx"], var.group_paths["m01_vc"], var.group_paths["m01_hosts"], var.group_paths["m01_avi_se"]]
    services           = [var.service_paths["https"], var.service_paths["tcp_8443"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name = "Avi Controller (Lock Down)"
    action       = "DROP"
    ip_version   = "IPV4"
    logged       = true
    log_label    = "m01_avi"
  }
}

resource "nsxt_policy_security_policy" "m01_ssp_policy" {
  display_name    = "Management Domain SSP"
  description     = "Management Domain SSP Policy"
  category        = "Application"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["m01_ssp"]]
  sequence_number = 10

  rule {
    display_name       = "SSP (Intra)"
    source_groups      = [var.group_paths["m01_ssp"]]
    destination_groups = [var.group_paths["m01_ssp"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name       = "SSP (In)"
    source_groups      = [var.group_paths["m01_nsx"], var.group_paths["m01_hosts"], var.group_paths["m01_edges"]]
    destination_groups = [var.group_paths["m01_ssp_svc"]]
    services           = [var.service_paths["https"], var.service_paths["tcp_9092"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "SSP (Out)"
    source_groups      = [var.group_paths["m01_ssp"]]
    destination_groups = [var.group_paths["m01_nsx"], var.group_paths["m01_vc"]]
    services           = [var.service_paths["https"], var.service_paths["tcp_1234_1235"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name = "SSP (Lock Down)"
    action       = "DROP"
    ip_version   = "IPV4"
    logged       = true
    log_label    = "m01_ssp"
  }
}
