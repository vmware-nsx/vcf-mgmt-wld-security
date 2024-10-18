data "nsxt_policy_service" "icmp_all" {
  display_name = "ICMP ALL"
}

data "nsxt_policy_service" "dns-tcp" {
  display_name = "DNS-TCP"
}

data "nsxt_policy_service" "activdir" {
  display_name = "Microsoft Active Directory V1"
}

data "nsxt_policy_service" "dns-udp" {
  display_name = "DNS-UDP"
}

data "nsxt_policy_service" "https" {
  display_name = "HTTPS"
}

data "nsxt_policy_service" "ldap" {
  display_name = "LDAP"
}

data "nsxt_policy_service" "ldaps" {
  display_name = "LDAP-over-SSL"
}

data "nsxt_policy_service" "ssh" {
  display_name = "SSH"
}

data "nsxt_policy_service" "syslog_udp" {
  display_name = "Syslog (UDP)"
}

data "nsxt_policy_service" "ntp" {
  display_name = "NTP"
}

data "nsxt_policy_context_profile" "ACTIVDIR" {
  display_name = "ACTIVDIR"
}

data "nsxt_policy_context_profile" "LDAP" {
  display_name = "LDAP"
}

data "nsxt_policy_context_profile" "DNS" {
  display_name = "DNS"
}

data "nsxt_policy_context_profile" "SSL" {
  display_name = "SSL"
}

data "nsxt_policy_context_profile" "DCERPC" {
  display_name = "DCERPC"
}

resource "nsxt_policy_security_policy" "vcf_infrastructure" {
  display_name = "VCF01 Infrastructure Policy"
  description  = "Control VCF01 Infrastructure traffic"
  category     = "Infrastructure"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.m01_wld.path, nsxt_policy_group.w01_wld.path]

   rule {
    display_name       = "Allow Bastion to VCF01"
    source_groups      = [nsxt_policy_group.bastion.path]
    destination_groups = [nsxt_policy_group.m01_wld.path, nsxt_policy_group.w01_wld.path]
    action             = "ALLOW"
    logged             = false
  }

    rule {
    display_name       = "Allow VCF01 to InfraSvc"
    source_groups      = [nsxt_policy_group.m01_wld.path, nsxt_policy_group.w01_wld.path]
    destination_groups = [nsxt_policy_group.infra_svc.path]
    services           = [data.nsxt_policy_service.dns-udp.path, data.nsxt_policy_service.dns-tcp.path, data.nsxt_policy_service.ntp.path, data.nsxt_policy_service.ssh.path, data.nsxt_policy_service.syslog_udp.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "Allow LDAP Traffic"
	source_groups      = [nsxt_policy_group.m01_wld.path, nsxt_policy_group.w01_wld.path, nsxt_policy_group.infra_svc.path]
    destination_groups = [nsxt_policy_group.m01_wld.path, nsxt_policy_group.w01_wld.path, nsxt_policy_group.infra_svc.path]
    action             = "ALLOW"
    logged             = false
    services           = [data.nsxt_policy_service.ldap.path]
  }

  rule {
    display_name       = "Allow AD Traffic"
    source_groups      = [nsxt_policy_group.m01_wld.path, nsxt_policy_group.w01_wld.path, nsxt_policy_group.infra_svc.path]
	destination_groups = [nsxt_policy_group.m01_wld.path, nsxt_policy_group.w01_wld.path, nsxt_policy_group.infra_svc.path]
    action             = "ALLOW"
    logged             = false
    profiles           = [data.nsxt_policy_context_profile.ACTIVDIR.path]
  }
  
    rule {
    display_name       = "Allow Automation and Management Tools"
	source_groups      = [nsxt_policy_group.tools.path]
    destination_groups = [nsxt_policy_group.m01_wld.path, nsxt_policy_group.w01_wld.path]
	services           = [data.nsxt_policy_service.https.path, data.nsxt_policy_service.icmp_all.path]
    action             = "ALLOW"
    logged             = false
  }
  
    rule {
    display_name       = "Allow Backup Traffic"
	source_groups      = [nsxt_policy_group.m01_wld.path, nsxt_policy_group.w01_wld.path]
    destination_groups = [nsxt_policy_group.backup_server.path]
	services           = [data.nsxt_policy_service.ssh.path, data.nsxt_policy_service.icmp_all.path]
    action             = "ALLOW"
    logged             = false
  }
}

resource "nsxt_policy_security_policy" "vcf_environment" {
  display_name = "VCF01 Environment Policy"
  description  = "Control VCF01 Environment traffic"
  category     = "Environment"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.m01_wld.path, nsxt_policy_group.w01_wld.path]
  
   rule {
    display_name       = "Allow VCF01 Management"
    source_groups      = [nsxt_policy_group.sddc_mgr.path]
    destination_groups = [nsxt_policy_group.m01_wld.path, nsxt_policy_group.w01_wld.path, nsxt_policy_group.m01_edges.path, nsxt_policy_group.m01_hosts.path, nsxt_policy_group.w01_edges.path, nsxt_policy_group.w01_hosts.path]
	services           = [data.nsxt_policy_service.https.path, data.nsxt_policy_service.ssh.path, nsxt_policy_service.tcp-5480.path, data.nsxt_policy_service.icmp_all.path]
    action             = "ALLOW"
    logged             = false
  }
  
    rule {
    display_name       = "Allow vCenter ELM"
    source_groups      = [nsxt_policy_group.sddc_mgr.path, nsxt_policy_group.m01_vc.path, nsxt_policy_group.w01_vc.path]
    destination_groups = [nsxt_policy_group.sddc_mgr.path, nsxt_policy_group.m01_vc.path, nsxt_policy_group.w01_vc.path]
	services           = [data.nsxt_policy_service.https.path, data.nsxt_policy_service.ldap.path, data.nsxt_policy_service.ldaps.path, nsxt_policy_service.tcp-elm.path]
    action             = "ALLOW"
    logged             = false
  }
  
    rule {
    display_name       = "Allow Management WLD to inself"
    source_groups      = [nsxt_policy_group.m01_wld.path, nsxt_policy_group.m01_edges.path, nsxt_policy_group.m01_hosts.path]
    destination_groups = [nsxt_policy_group.m01_wld.path, nsxt_policy_group.m01_edges.path, nsxt_policy_group.m01_hosts.path]
    action             = "ALLOW"
    logged             = false
  }
  
    rule {
    display_name       = "Allow VI WLD01 to inself"
    source_groups      = [nsxt_policy_group.w01_wld.path, nsxt_policy_group.w01_edges.path, nsxt_policy_group.w01_hosts.path, nsxt_policy_group.w01_nfs.path]
    destination_groups = [nsxt_policy_group.w01_wld.path, nsxt_policy_group.w01_edges.path, nsxt_policy_group.w01_hosts.path, nsxt_policy_group.w01_nfs.path]
    action             = "ALLOW"
    logged             = false
  }
  
    rule {
    display_name       = "Block traffic between WLDs"
    source_groups      = [nsxt_policy_group.w01_wld.path, nsxt_policy_group.m01_wld.path]
    destination_groups = [nsxt_policy_group.w01_wld.path, nsxt_policy_group.m01_wld.path]
    action             = "DROP"
    logged             = true
  }
  
    rule {
    display_name       = "Allow VCF01 Outbound"
    source_groups      = [nsxt_policy_group.m01_wld.path, nsxt_policy_group.w01_wld.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }
  
    rule {
    display_name       = "VCF01 Default Drop"
    action             = "DROP"
    logged             = true
	log_label          = "vcf01"
  }
}
