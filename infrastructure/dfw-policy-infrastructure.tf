# Infrastructure category policy (evaluated first, before Environment and Application).
# Allows the fleet to reach DNS, NTP, DHCP and Active Directory, and drops and logs DNS, NTP and DHCP
# traffic to any other destination. Syslog is allowed in the Environment category ("VCF Fleet External").
# Policy sequence number: 1.

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
    destination_groups = [nsxt_policy_group.dns_svc.path]
    services           = [var.service_paths["dns_udp"], var.service_paths["dns_tcp"]]
    profiles           = [var.context_profile_paths["dns"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "NTP"
    destination_groups = [nsxt_policy_group.ntp_svc.path]
    services           = [var.service_paths["ntp"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "DHCP"
    destination_groups = [nsxt_policy_group.dhcp_svc.path]
    services           = [var.service_paths["dhcp_server"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "AD"
    destination_groups = [nsxt_policy_group.ad_svc.path]
    services           = [var.service_paths["activdir"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name = "VCF Fleet Infrastructure (Lock Down)"
    services     = [var.service_paths["dns_udp"], var.service_paths["dns_tcp"], var.service_paths["ntp"], var.service_paths["dhcp_server"]]
    action       = "DROP"
    ip_version   = "IPV4"
    direction    = "OUT"
    logged       = true
    log_label    = "infra"
  }
}
