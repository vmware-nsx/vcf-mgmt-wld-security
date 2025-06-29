resource "nsxt_policy_security_policy" "vcf_mgmt" {
  display_name = "VCF01 Management Policy"
  description  = "Control VCF01 Management traffic"
  category     = "Environment"
  locked       = false
  stateful     = true
  tcp_strict   = true
  sequence_number = 1

  rule {
    display_name       = "Bastion to VCF01 Traffic"
    source_groups      = [nsxt_policy_group.bastion.path]
	services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.ssh.path,data.nsxt_policy_service.icmp_all.path,data.nsxt_policy_service.rdp.path]
	scope              = [nsxt_policy_group.vcf01.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "VCF01 HTTPS and SSH for management"
    source_groups      = [nsxt_policy_group.vcf01_mgmt.path]
	destination_groups = [nsxt_policy_group.m01_wld.path,nsxt_policy_group.w01_wld.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.ssh.path]
    scope              = [nsxt_policy_group.vcf01.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SDDC Management Traffic"
    source_groups      = [nsxt_policy_group.sddc_mgr.path]
	destination_groups = [nsxt_policy_group.m01_wld.path,nsxt_policy_group.w01_wld.path]
    services           = [nsxt_policy_service.tcp_5480.path,data.nsxt_policy_service.icmp_all.path]
    scope              = [nsxt_policy_group.vcf01.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "vCenter ELM Traffic"
    source_groups      = [nsxt_policy_group.sddc_mgr.path, nsxt_policy_group.elm_vc.path]
    destination_groups = [nsxt_policy_group.sddc_mgr.path, nsxt_policy_group.elm_vc.path]
    services           = [data.nsxt_policy_service.ldap.path, data.nsxt_policy_service.ldaps.path, nsxt_policy_service.tcp_2012_2020.path]
    scope              = [nsxt_policy_group.sddc_mgr.path,nsxt_policy_group.elm_vc.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "vCenter RDU"
    source_groups      = [nsxt_policy_group.vcf01_mgmt.path]
    destination_groups = [nsxt_policy_group.vcf01_mgmt.path]
    services           = [nsxt_policy_service.tcp_5480.path,nsxt_policy_service.tcp_5432.path]
    scope              = [nsxt_policy_group.vcf01_mgmt.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "Broadcom Depot Traffic"
    source_groups      = [nsxt_policy_group.vcf01_mgmt.path]
    services           = [data.nsxt_policy_service.https.path]
    profiles           = [nsxt_policy_context_profile.internet_fqdns.path]
    scope              = [nsxt_policy_group.vcf01_mgmt.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "Block insecure protocols"
    services           = [data.nsxt_policy_service.rdp.path]
	scope              = [nsxt_policy_group.vcf01.path]
    action             = "DROP"
    logged             = false
  }
}

resource "nsxt_policy_security_policy" "m01_ssp_policy" {
  display_name = "M01_WLD SSP Policy"
  description  = "Control Management workload domain SSP traffic"
  category     = "Environment"
  locked       = false
  stateful     = true
  tcp_strict   = true
  sequence_number = 3

  rule {
    display_name       = "All SSPs to vCenter"
    source_groups      = [nsxt_policy_group.vcf01_ssp.path]
    destination_groups = [nsxt_policy_group.m01_vc.path]
	services           = [data.nsxt_policy_service.https.path]
    scope              = [nsxt_policy_group.m01_vc.path,nsxt_policy_group.vcf01_ssp.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SSP to NSX Manager"
    source_groups      = [nsxt_policy_group.m01_ssp.path]
    destination_groups = [nsxt_policy_group.m01_nsx.path]
	services           = [data.nsxt_policy_service.https.path]
    scope              = [nsxt_policy_group.m01_nsx.path,nsxt_policy_group.m01_ssp.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SSPI to SSP"
    source_groups      = [nsxt_policy_group.m01_sspi.path]
    destination_groups = [nsxt_policy_group.m01_ssp.path]
    services           = [nsxt_policy_service.tcp_6443.path,data.nsxt_policy_service.https.path]
    scope              = [nsxt_policy_group.m01_sspi.path,nsxt_policy_group.m01_ssp.path]
    action             = "ALLOW"
    logged             = false
  }
    
  rule {
    display_name       = "SSP to SSPI Registry"
    source_groups      = [nsxt_policy_group.m01_ssp.path]
	destination_groups = [nsxt_policy_group.m01_sspi.path]
    services           = [data.nsxt_policy_service.https.path]
    scope              = [nsxt_policy_group.m01_sspi.path,nsxt_policy_group.m01_ssp.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "SSP Ingestion"
    source_groups      = [nsxt_policy_group.m01_nsx.path,nsxt_policy_group.m01_hosts.path,nsxt_policy_group.m01_edges.path]
	destination_groups = [nsxt_policy_group.m01_sspm.path]
    services           = [data.nsxt_policy_service.https.path,nsxt_policy_service.tcp_9092.path]
    scope              = [nsxt_policy_group.m01_ssp.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "SSP Feeds"
    source_groups      = [nsxt_policy_group.m01_ssp.path]
    services           = [data.nsxt_policy_service.https.path]
    scope              = [nsxt_policy_group.m01_ssp.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "SSP to SIEM Server"
	source_groups      = [nsxt_policy_group.m01_ssp.path]
	destination_groups = [nsxt_policy_group.siem_svc.path]
	services           = [data.nsxt_policy_service.https.path]
    scope              = [nsxt_policy_group.m01_ssp.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "SSP Internal"
    source_groups      = [nsxt_policy_group.m01_ssp.path]
    destination_groups = [nsxt_policy_group.m01_ssp.path]
    scope              = [nsxt_policy_group.m01_ssp.path]
    action             = "ALLOW"
    logged             = false
  }
}

resource "nsxt_policy_security_policy" "m01_policy" {
  display_name = "M01_WLD Policy"
  description  = "Control Management workload domain traffic"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = true
  sequence_number = 1

  rule {
    display_name       = "vCenter to Hosts"
    source_groups      = [nsxt_policy_group.m01_vc.path]
    destination_groups = [nsxt_policy_group.m01_hosts.path]
    services           = [data.nsxt_policy_service.update_manager.path,data.nsxt_policy_service.icmp_all.path]
    action             = "ALLOW"
    scope              = [nsxt_policy_group.m01_vc.path,]
    logged             = false
  }
  
  rule {
    display_name       = "Hosts to vCenter"
    source_groups      = [nsxt_policy_group.m01_hosts.path]
    destination_groups = [nsxt_policy_group.m01_vc.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.tcp_9087.path,data.nsxt_policy_service.tcp_9084.path,data.nsxt_policy_service.udp_902.path,nsxt_policy_service.tcp_6500.path,nsxt_policy_service.tcp_6501_6502.path,nsxt_policy_service.tcp_7475_7476.path]
    action             = "ALLOW"
    scope              = [nsxt_policy_group.m01_vc.path,]
    logged             = false
  }

  rule {
    display_name       = "NSX to vCenter"
    source_groups      = [nsxt_policy_group.m01_nsx.path]
    destination_groups = [nsxt_policy_group.m01_vc.path]
    services           = [data.nsxt_policy_service.http.path,data.nsxt_policy_service.tcp_9087.path]
    action             = "ALLOW"
    scope              = [nsxt_policy_group.m01_vc.path]
    logged             = false
  }

# Not applicable for the management domain NSX manager  
#  rule {
#    display_name       = "NSX Messaging"
#    source_groups      = [nsxt_policy_group.m01_nsx.path,nsxt_policy_group.m01_hosts.path,nsxt_policy_group.m01_edges.path]
#    destination_groups = [nsxt_policy_group.m01_nsx.path,nsxt_policy_group.m01_hosts.path,nsxt_policy_group.m01_edges.path]
#    services           = [nsxt_policy_service.tcp_1234_1235.path,nsxt_policy_service.tcp_5671.path]
#    action             = "ALLOW"
#    scope              = [nsxt_policy_group.m01_nsx.path]
#    logged             = false
#  }

#  rule {
#    display_name       = "NSX Manager Cluster"
#    source_groups      = [nsxt_policy_group.m01_nsx.path]
#    destination_groups = [nsxt_policy_group.m01_nsx.path]
#    services           = [nsxt_policy_service.tcp_9000.path,nsxt_policy_service.tcp_9040.path,data.nsxt_policy_service.icmp_all.path]
#    action             = "ALLOW"
#    scope              = [nsxt_policy_group.m01_nsx.path]
#    logged             = false
#  }

  rule {
    display_name       = "M01_WLD Default Drop"
    scope              = [nsxt_policy_group.m01_wld.path]
    action             = "DROP"
    logged             = true
    log_label          = "m01_wld"
  }
}
