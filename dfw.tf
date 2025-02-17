resource "nsxt_policy_security_policy" "vcf_infrastructure" {
  display_name = "VCF01 Infrastructure Policy"
  description  = "Control VCF01 Infrastructure traffic"
  category     = "Infrastructure"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.vcf01.path]
  sequence_number = 1

   rule {
    display_name       = "Bastion to VCF01 Traffic"
    source_groups      = [nsxt_policy_group.bastion.path]
    destination_groups = [nsxt_policy_group.vcf01.path]
    action             = "ALLOW"
    logged             = false
  }

    rule {
    display_name       = "VCF01 DNS Traffic"
    source_groups      = [nsxt_policy_group.vcf01.path]
    destination_groups = [nsxt_policy_group.dns_svc.path]
    services           = [data.nsxt_policy_service.dns_udp.path, data.nsxt_policy_service.dns_tcp.path]
    action             = "ALLOW"
    logged             = false
  }

    rule {
    display_name       = "VCF01 NTP Traffic"
    source_groups      = [nsxt_policy_group.vcf01.path]
    destination_groups = [nsxt_policy_group.ntp_svc.path]
    services           = [data.nsxt_policy_service.ntp.path]
    action             = "ALLOW"
    logged             = false
  }

    rule {
    display_name       = "VCF01 DHCP Traffic"
    source_groups      = [nsxt_policy_group.vcf01.path]
    destination_groups = [nsxt_policy_group.dhcp_svc.path]
    services           = [data.nsxt_policy_service.dhcp_server.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "VCF01 AD Traffic"
    source_groups      = [nsxt_policy_group.vcf01.path]
    destination_groups = [nsxt_policy_group.ad_svc.path]
    action             = "ALLOW"
    logged             = false
    services           = [data.nsxt_policy_service.ldap.path,data.nsxt_policy_service.ldap_udp.path,data.nsxt_policy_service.ldaps.path,data.nsxt_policy_service.kerberos.path,data.nsxt_policy_service.kerberos_udp.path,nsxt_policy_service.tcp_3268_3269.path]
  }

    rule {
    display_name       = "VCF01 Mail Server Traffic"
    source_groups      = [nsxt_policy_group.vcf01.path]
    destination_groups = [nsxt_policy_group.smtp_svc.path]
    services           = [data.nsxt_policy_service.smtp.path,data.nsxt_policy_service.smtp_tls.path]
    action             = "ALLOW"
    logged             = false
  }

    rule {
    display_name       = "VCF01 Automation and Management Tools"
    source_groups      = [nsxt_policy_group.tools.path]
    destination_groups = [nsxt_policy_group.vcf01.path ]
    services           = [data.nsxt_policy_service.https.path, data.nsxt_policy_service.icmp_all.path]
    action             = "ALLOW"
    logged             = false
  }

    rule {
    display_name       = "VCF01 Backup Traffic"
    source_groups      = [nsxt_policy_group.vcf01.path]
    destination_groups = [nsxt_policy_group.backup_server.path]
    services           = [data.nsxt_policy_service.ssh.path,data.nsxt_policy_service.ftp.path,data.nsxt_policy_service.icmp_all.path]
    action             = "ALLOW"
    logged             = false
  }
}

resource "nsxt_policy_security_policy" "vcf_mgmt" {
  display_name = "VCF01 Management Policy"
  description  = "Control VCF01 Management traffic"
  category     = "Environment"
  locked       = false
  stateful     = true
  tcp_strict   = true
  sequence_number = 1

   rule {
    display_name       = "VCF01 HTTPS and SSH for management"
    source_groups      = [nsxt_policy_group.vcf01_mgmt.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.ssh.path]
    scope              = [nsxt_policy_group.vcf01.path]
    action             = "ALLOW"
    logged             = false
  }

   rule {
    display_name       = "SDDC Management Traffic"
    source_groups      = [nsxt_policy_group.sddc_mgr.path]
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
}

resource "nsxt_policy_security_policy" "vcf_aria" {
  display_name = "Aria Suite Management Policy"
  description  = "Control Aria Suite traffic"
  category     = "Environment"
  locked       = false
  stateful     = true
  tcp_strict   = true
  sequence_number = 2

    rule {
    display_name       = "Aria Suite Internal Traffic"
    source_groups      = [nsxt_policy_group.aria_suite.path]
    destination_groups = [nsxt_policy_group.aria_suite.path]
    scope              = [nsxt_policy_group.aria_suite.path]
    action             = "ALLOW"
    logged             = false
  }

    rule {
    display_name       = "Aria Suite Inbound Traffic"
    source_groups      = [nsxt_policy_group.m01_wld.path]
    destination_groups = [nsxt_policy_group.aria_suite.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.ssh.path,data.nsxt_policy_service.syslog_udp.path,data.nsxt_policy_service.syslog_tcp.path,nsxt_policy_service.tcp_9000.path,nsxt_policy_service.tcp_9543.path,nsxt_policy_service.tcp_1514.path,nsxt_policy_service.tcp_6514.path]
    scope              = [nsxt_policy_group.vcf01.path]
    action             = "ALLOW"
    logged             = false
  }
    
    rule {
    display_name       = "Aria Suite Outbound Traffic"
    source_groups      = [nsxt_policy_group.aria_suite.path]
    services           = [data.nsxt_policy_service.icmp_all.path,data.nsxt_policy_service.https.path,data.nsxt_policy_service.ssh.path,data.nsxt_policy_service.snmp.path,data.nsxt_policy_service.syslog_udp.path,data.nsxt_policy_service.syslog_tcp.path,nsxt_policy_service.tcp_9000.path,nsxt_policy_service.tcp_9543.path]
    scope              = [nsxt_policy_group.vcf01.path]
    action             = "ALLOW"
    logged             = false
  }

    rule {
    display_name       = "Aria Suite Default Drop"
    scope              = [nsxt_policy_group.aria_suite.path]
    action             = "DROP"
    logged             = true
    log_label          = "aria_suite"
  }
}

resource "nsxt_policy_security_policy" "vcf_supervizor" {
  display_name = "vSphere Supervizor Policy"
  description  = "Control Supervizor traffic"
  category     = "Environment"
  locked       = false
  stateful     = true
  tcp_strict   = true
  sequence_number = 3

    rule {
    display_name       = "Supervizor Internal Traffic"
    source_groups      = [nsxt_policy_group.vcf01_sup.path]
    destination_groups = [nsxt_policy_group.vcf01_sup.path]
    scope              = [nsxt_policy_group.vcf01_sup.path]
    action             = "ALLOW"
    logged             = false
  }

    rule {
    display_name       = "Supervizor Inbound Traffic"
    source_groups      = [nsxt_policy_group.m01_wld.path]
    destination_groups = [nsxt_policy_group.vcf01_sup.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.http.path,nsxt_policy_service.tcp_6443.path,nsxt_policy_service.tcp_8443.path,nsxt_policy_service.tcp_5000.path]
    scope              = [nsxt_policy_group.vcf01.path]
    action             = "ALLOW"
    logged             = false
  }
    
    rule {
    display_name       = "Supervizor Outbound Traffic"
    source_groups      = [nsxt_policy_group.vcf01_sup.path]
    services           = [data.nsxt_policy_service.https.path]
    scope              = [nsxt_policy_group.vcf01.path]
    action             = "ALLOW"
    logged             = false
  }

    rule {
    display_name       = "Supervizor Default Drop"
    scope              = [nsxt_policy_group.vcf01_sup.path]
    action             = "DROP"
    logged             = true
    log_label          = "vcf01_sup"
  }
}


resource "nsxt_policy_security_policy" "vcf_bad_protocols" {
  display_name = "Bad Protocolst Policy"
  description  = "Control VCF01 Bad Protocolst Policy traffic"
  category     = "Environment"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.vcf01.path]
  sequence_number = 4

    rule {
    display_name       = "Block insecure protocols"
    services           = [data.nsxt_policy_service.rdp.path]
    action             = "DROP"
    logged             = false
  }
}

resource "nsxt_policy_security_policy" "m01_policy" {
  display_name = "Management workload domain policy"
  description  = "Control Management workload domain traffic"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = true
  sequence_number = 0

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
