resource "nsxt_policy_security_policy" "m01_vc_policy" {
  display_name = "Menagement Domain vCenter Policy"
  description  = "Menagement Domain vCenter Policy"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.m01_vc.path]
  sequence_number = 5

  rule {
    display_name       = "vCenter to Hosts"
    source_groups      = [nsxt_policy_group.m01_vc.path]
    destination_groups = [nsxt_policy_group.m01_hosts.path]
    services           = [data.nsxt_policy_service.update_manager.path,data.nsxt_policy_service.icmp_all.path,nsxt_policy_service.tcp_1443.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "Hosts to vCenter"
    source_groups      = [nsxt_policy_group.m01_hosts.path]
    destination_groups = [nsxt_policy_group.m01_vc.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.tcp_9087.path,data.nsxt_policy_service.tcp_9084.path,data.nsxt_policy_service.udp_902.path,nsxt_policy_service.tcp_6500.path,nsxt_policy_service.tcp_6501_6502.path,nsxt_policy_service.tcp_7475_7476.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "vCenter to NSX"
    source_groups      = [nsxt_policy_group.m01_vc.path]
    destination_groups = [nsxt_policy_group.m01_nsx.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "NSX to vCenter"
    source_groups      = [nsxt_policy_group.m01_nsx.path]
    destination_groups = [nsxt_policy_group.m01_vc.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.http.path,data.nsxt_policy_service.tcp_9087.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "SSPI and SSPs to vCenter"
    source_groups      = [nsxt_policy_group.m01_sspi.path,nsxt_policy_group.m01_ssp.path]
    destination_groups = [nsxt_policy_group.m01_vc.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "Avi to VCF01 Management domain"
    source_groups      = [nsxt_policy_group.m01_avi.path]
    destination_groups = [nsxt_policy_group.m01_vc.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "vCenter Lock Down"
    scope              = [nsxt_policy_group.m01_vc.path]
    action             = "DROP"
    logged             = true
    log_label          = "m01_vc"
  }
}

resource "nsxt_policy_security_policy" "m01_avi_policy" {
  display_name = "Management Domain Avi Policy"
  description  = "Management Domain Avi Policy"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.m01_avi.path]
  sequence_number = 6

  rule {
    display_name       = "Avi controller cluster"
    source_groups      = [nsxt_policy_group.m01_avi.path]
    destination_groups = [nsxt_policy_group.m01_avi.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "Avi to VCF01 Management domain"
    source_groups      = [nsxt_policy_group.m01_avi.path]
    destination_groups = [nsxt_policy_group.m01_vc.path,nsxt_policy_group.m01_nsx.path,nsxt_policy_group.m01_hosts.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "Avi to/from SE Management"
    source_groups      = [nsxt_policy_group.m01_avi.path,nsxt_policy_group.m01_avi_se.path]
    destination_groups = [nsxt_policy_group.m01_avi.path,nsxt_policy_group.m01_avi_se.path]
    services           = [data.nsxt_policy_service.ssh.path,nsxt_policy_service.tcp_8443.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "Avi Lock Down"
    action             = "DROP"
    logged             = true
    log_label          = "m01_avi"
  }
}

resource "nsxt_policy_security_policy" "m01_ssp_policy" {
  display_name = "Management Domain SSP Policy"
  description  = "Management Domain SSP Policy"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.m01_sspi.path,nsxt_policy_group.m01_ssp.path]
  sequence_number = 7

  rule {
    display_name       = "SSPI and SSPs to vCenter"
    source_groups      = [nsxt_policy_group.m01_sspi.path,nsxt_policy_group.m01_ssp.path]
    destination_groups = [nsxt_policy_group.m01_vc.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SSP to NSX Manager"
    source_groups      = [nsxt_policy_group.m01_ssp.path]
    destination_groups = [nsxt_policy_group.m01_nsx.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SSPI to SSP"
    source_groups      = [nsxt_policy_group.m01_sspi.path]
    destination_groups = [nsxt_policy_group.m01_ssp.path]
    services           = [nsxt_policy_service.tcp_6443.path,data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SSP to SSPI Registry"
    source_groups      = [nsxt_policy_group.m01_ssp.path]
    destination_groups = [nsxt_policy_group.m01_sspi.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SSP Ingestion"
    source_groups      = [nsxt_policy_group.m01_nsx.path,nsxt_policy_group.m01_hosts.path,nsxt_policy_group.m01_edges.path]
    destination_groups = [nsxt_policy_group.m01_sspm.path]
    services           = [data.nsxt_policy_service.https.path,nsxt_policy_service.tcp_9092.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SSP Feeds"
    source_groups      = [nsxt_policy_group.m01_ssp.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SSP Internal"
    source_groups      = [nsxt_policy_group.m01_ssp.path]
    destination_groups = [nsxt_policy_group.m01_ssp.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "Management Domain SSP Lock Down"
    action             = "DROP"
    logged             = true
    log_label          = "m01_ssp"
  }
}