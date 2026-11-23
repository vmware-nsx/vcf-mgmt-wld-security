# Infrastructure category policy (evaluated first, before Environment and Application).
# Allows the fleet to reach DNS, NTP, DHCP, Active Directory and, when configured, the external syslog
# collector, and drops and logs DNS, NTP, DHCP and syslog traffic to any other destination.
# Policy sequence number: 1.

locals {
  syslog_enabled = contains(keys(var.group_paths), "syslog_svc")
}

resource "nsxt_policy_security_policy" "vcf_infrastructure" {
  display_name    = "VCF Fleet Infrastructure"
  description     = "Control VCF Infrastructure traffic"
  category        = "Infrastructure"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["vcf_fleet"]]
  sequence_number = 1

  rule {
    display_name       = "DNS"
    destination_groups = [var.group_paths["dns_svc"]]
    services           = [var.service_paths["dns_udp"], var.service_paths["dns_tcp"]]
    profiles           = [var.context_profile_paths["dns"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "NTP"
    destination_groups = [var.group_paths["ntp_svc"]]
    services           = [var.service_paths["ntp"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "DHCP"
    destination_groups = [var.group_paths["dhcp_svc"]]
    services           = [var.service_paths["dhcp_server"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "AD"
    destination_groups = [var.group_paths["ad_svc"]]
    services           = [var.service_paths["activdir"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  # Only present when an external syslog collector is configured (external_services.syslog_server).
  dynamic "rule" {
    for_each = local.syslog_enabled ? [1] : []

    content {
      display_name       = "Syslog"
      destination_groups = [var.group_paths["syslog_svc"]]
      services           = [var.service_paths["syslog_tcp"], var.service_paths["syslog_udp"]]
      action             = "ALLOW"
      ip_version         = "IPV4_IPV6"
      direction          = "OUT"
      logged             = false
    }
  }

  rule {
    display_name = "VCF Fleet Infrastructure (Lock Down)"
    services     = concat([var.service_paths["dns_udp"], var.service_paths["dns_tcp"], var.service_paths["ntp"], var.service_paths["dhcp_server"]], local.syslog_enabled ? [var.service_paths["syslog_tcp"], var.service_paths["syslog_udp"]] : [])
    action       = "DROP"
    ip_version   = "IPV4"
    direction    = "OUT"
    logged       = true
    log_label    = "infra"
  }
}
