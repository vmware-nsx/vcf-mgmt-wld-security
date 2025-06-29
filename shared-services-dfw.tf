resource "nsxt_policy_security_policy" "vcf_infrastructure" {
  display_name = "VCF01 Shared Services Policy"
  description  = "Control VCF01 Shared Services traffic"
  category     = "Infrastructure"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.vcf01.path]
  sequence_number = 1

  rule {
    display_name       = "VCF01 DNS Traffic"
    source_groups      = [nsxt_policy_group.vcf01.path]
    destination_groups = [nsxt_policy_group.dns_svc.path]
    services           = [data.nsxt_policy_service.dns_udp.path,data.nsxt_policy_service.dns_tcp.path]
	profiles           = [data.nsxt_policy_context_profile.cxt_dns.path]
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
    services           = [data.nsxt_policy_service.activdir.path]
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
    destination_groups = [nsxt_policy_group.backup_svc.path]
    services           = [data.nsxt_policy_service.ssh.path,data.nsxt_policy_service.ftp.path,data.nsxt_policy_service.icmp_all.path]
    action             = "ALLOW"
    logged             = false
  }
}