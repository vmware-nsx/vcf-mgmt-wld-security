resource "nsxt_policy_security_policy" "w01_vc_policy" {
  display_name = "Workload Domain 01 vCenter Policy"
  description  = "Workload Domain 01 vCenter Policy"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.w01_vc.path]
  sequence_number = 9

  rule {
    display_name       = "vCenter to Hosts"
    source_groups      = [nsxt_policy_group.w01_vc.path]
    destination_groups = [nsxt_policy_group.w01_hosts.path]
    services           = [data.nsxt_policy_service.update_manager.path,data.nsxt_policy_service.icmp_all.path,nsxt_policy_service.tcp_1443.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "Hosts to vCenter"
    source_groups      = [nsxt_policy_group.w01_hosts.path]
    destination_groups = [nsxt_policy_group.w01_vc.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.tcp_9087.path,data.nsxt_policy_service.tcp_9084.path,data.nsxt_policy_service.udp_902.path,nsxt_policy_service.tcp_6500.path,nsxt_policy_service.tcp_6501_6502.path,nsxt_policy_service.tcp_7475_7476.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "vCenter to NSX"
    source_groups      = [nsxt_policy_group.w01_vc.path]
    destination_groups = [nsxt_policy_group.w01_nsx.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "NSX to vCenter"
    source_groups      = [nsxt_policy_group.w01_nsx.path]
    destination_groups = [nsxt_policy_group.w01_vc.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.http.path,data.nsxt_policy_service.tcp_9087.path]
    action             = "ALLOW"
    logged             = false
  }
  
 # rule {
 #   display_name       = "SSPI and SSPs to vCenter"
 #   source_groups      = [nsxt_policy_group.w01_sspi.path,nsxt_policy_group.w01_ssp.path]
 #   destination_groups = [nsxt_policy_group.w01_vc.path]
 #   services           = [data.nsxt_policy_service.https.path]
 #   action             = "ALLOW"
 #   logged             = false
 # }

  rule {
    display_name       = "Avi to VCF01 Workload Domain 01"
    source_groups      = [nsxt_policy_group.w01_avi.path]
    destination_groups = [nsxt_policy_group.w01_vc.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "vCenter to Supervisor"
    source_groups      = [nsxt_policy_group.w01_vc.path]
    destination_groups = [nsxt_policy_group.w01_sup01.path]
    services           = [nsxt_policy_service.tcp_6443.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "Supervisor to vCenter"
    source_groups      = [nsxt_policy_group.w01_sup01.path]
    destination_groups = [nsxt_policy_group.w01_vc.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "vCenter Lock Down"
    scope              = [nsxt_policy_group.w01_vc.path]
    action             = "DROP"
    logged             = true
    log_label          = "w01_vc"
  }
}

resource "nsxt_policy_security_policy" "w01_nsx_policy" {
  display_name = "Workload Domain 01 NSX Policy"
  description  = "Workload Domain 01 NSX Policy"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.w01_nsx.path]
  sequence_number = 10

  rule {
    display_name       = "NSX Messaging"
    source_groups      = [nsxt_policy_group.w01_nsx.path,nsxt_policy_group.w01_hosts.path,nsxt_policy_group.w01_edges.path]
    destination_groups = [nsxt_policy_group.w01_nsx.path,nsxt_policy_group.w01_hosts.path,nsxt_policy_group.w01_edges.path]
    services           = [nsxt_policy_service.tcp_1234_1235.path,nsxt_policy_service.tcp_5671.path]
    action             = "ALLOW"
    scope              = [nsxt_policy_group.w01_nsx.path]
    logged             = false
  }

  rule {
    display_name       = "vCenter to NSX"
    source_groups      = [nsxt_policy_group.w01_vc.path]
    destination_groups = [nsxt_policy_group.w01_nsx.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "NSX to vCenter"
    source_groups      = [nsxt_policy_group.w01_nsx.path]
    destination_groups = [nsxt_policy_group.w01_vc.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.http.path,data.nsxt_policy_service.tcp_9087.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "NSX Manager Cluster"
    source_groups      = [nsxt_policy_group.w01_nsx.path]
    destination_groups = [nsxt_policy_group.w01_nsx.path]
    services           = [nsxt_policy_service.tcp_9000.path,nsxt_policy_service.tcp_9040.path,data.nsxt_policy_service.icmp_all.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "Avi to VCF01 Workload Domain 01 NSX"
    source_groups      = [nsxt_policy_group.w01_avi.path]
    destination_groups = [nsxt_policy_group.w01_nsx.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "Supervisor to NSX"
    source_groups      = [nsxt_policy_group.w01_sup01.path]
    destination_groups = [nsxt_policy_group.w01_nsx.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "NSX Lock Down"
    action             = "DROP"
    logged             = true
    log_label          = "w01_nsx"
  }
}

resource "nsxt_policy_security_policy" "w01_avi_policy" {
  display_name = "Workload Domain 01 Avi Policy"
  description  = "Workload Domain 01 Avi Policy"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.w01_avi.path,nsxt_policy_group.w01_avi_se.path]
  sequence_number = 11

  rule {
    display_name       = "Avi to VCF01 Workload Domain 01"
    source_groups      = [nsxt_policy_group.w01_avi.path]
    destination_groups = [nsxt_policy_group.w01_vc.path,nsxt_policy_group.w01_nsx.path,nsxt_policy_group.w01_hosts.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "Avi to SE Management"
    source_groups      = [nsxt_policy_group.w01_avi.path]
    destination_groups = [nsxt_policy_group.w01_avi_se.path]
    services           = [nsxt_policy_service.tcp_8443.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SE Management to Avi"
    source_groups      = [nsxt_policy_group.w01_avi_se.path]
    destination_groups = [nsxt_policy_group.w01_avi.path]
    services           = [data.nsxt_policy_service.ssh.path,nsxt_policy_service.tcp_8443.path]
    action             = "ALLOW"
    scope              = [nsxt_policy_group.w01_avi.path,nsxt_policy_group.w01_avi_se.path]
    logged             = false
  }

  rule {
    display_name       = "Avi Lock Down"
    scope              = [nsxt_policy_group.w01_avi.path]
    action             = "DROP"
    logged             = true
    log_label          = "w01_avi"
  }
}

resource "nsxt_policy_security_policy" "w01_ssp_policy" {
  display_name = "Workload Domain 01 SSP Policy"
  description  = "Workload Domain 01 SSP Policy"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope              = [nsxt_policy_group.w01_sspi.path,nsxt_policy_group.w01_ssp.path]
  sequence_number = 12

  rule {
    display_name       = "SSPI and SSPs to vCenter"
    source_groups      = [nsxt_policy_group.w01_sspi.path,nsxt_policy_group.w01_ssp.path]
    destination_groups = [nsxt_policy_group.w01_vc.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SSP to NSX Manager"
    source_groups      = [nsxt_policy_group.w01_ssp.path]
    destination_groups = [nsxt_policy_group.w01_nsx.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SSPI to SSP"
    source_groups      = [nsxt_policy_group.w01_sspi.path]
    destination_groups = [nsxt_policy_group.w01_ssp.path]
    services           = [nsxt_policy_service.tcp_6443.path,data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SSP to SSPI Registry"
    source_groups      = [nsxt_policy_group.w01_ssp.path]
    destination_groups = [nsxt_policy_group.w01_sspi.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SSP Ingestion"
    source_groups      = [nsxt_policy_group.w01_nsx.path,nsxt_policy_group.w01_hosts.path,nsxt_policy_group.w01_edges.path]
    destination_groups = [nsxt_policy_group.w01_sspm.path]
    services           = [data.nsxt_policy_service.https.path,nsxt_policy_service.tcp_9092.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SSP Feeds"
    source_groups      = [nsxt_policy_group.w01_ssp.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SSP to SIEM Server"
    source_groups      = [nsxt_policy_group.w01_ssp.path]
    destination_groups = [nsxt_policy_group.siem_svc.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SSP Internal"
    source_groups      = [nsxt_policy_group.w01_ssp.path]
    destination_groups = [nsxt_policy_group.w01_ssp.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "Workload Domain 01 SSP Lock Down"
    action             = "DROP"
    logged             = true
    log_label          = "w01_ssp"
  }
}