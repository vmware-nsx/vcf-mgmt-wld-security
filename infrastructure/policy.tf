resource "nsxt_policy_security_policy" "vcf_infrastructure" {
  display_name    = "VCF Infrastructure Policy"
  description     = "Control VCF Infrastructure traffic"
  category        = "Infrastructure"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["vcf_f"]]
  sequence_number = 1

  rule {
    display_name       = "VCF01 DNS Traffic"
    destination_groups = [nsxt_policy_group.dns_svc.path]
    services           = [data.nsxt_policy_service.dns_udp.path, data.nsxt_policy_service.dns_tcp.path]
    profiles           = [data.nsxt_policy_context_profile.cxt_dns.path]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "VCF01 NTP Traffic"
    destination_groups = [nsxt_policy_group.ntp_svc.path]
    services           = [data.nsxt_policy_service.ntp.path]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "VCF01 DHCP Traffic"
    destination_groups = [nsxt_policy_group.dhcp_svc.path]
    services           = [data.nsxt_policy_service.dhcp_server.path]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "VCF01 AD Traffic"
    destination_groups = [nsxt_policy_group.ad_svc.path]
    services           = [data.nsxt_policy_service.activdir.path]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false

  }

  rule {
    display_name       = "VCF01 Syslog Traffic"
    destination_groups = [var.group_paths["vcf_ops_logs"]]
    services           = [data.nsxt_policy_service.syslog_tcp.path, data.nsxt_policy_service.syslog_udp.path, local.tcp_9543]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "VCF Fleet Management Lock Down"
    services           = [data.nsxt_policy_service.dns_udp.path, data.nsxt_policy_service.dns_tcp.path, data.nsxt_policy_service.ntp.path, data.nsxt_policy_service.dhcp_server.path]
    action             = "DROP"
    direction          = "OUT"
    logged             = true
    log_label          = "infra"
  }
}
