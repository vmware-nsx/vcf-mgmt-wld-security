data "nsxt_policy_service" "dns_tcp" {
  display_name = "DNS-TCP"
}

data "nsxt_policy_service" "dns_udp" {
  display_name = "DNS-UDP"
}

data "nsxt_policy_service" "activdir" {
  display_name = "Microsoft Active Directory V1"
}

data "nsxt_policy_service" "dhcp_server" {
  display_name = "DHCP-Server"
}

data "nsxt_policy_service" "ntp" {
  display_name = "NTP"
}

data "nsxt_policy_service" "syslog_udp" {
  display_name = "Syslog (UDP)"
}

data "nsxt_policy_service" "syslog_tcp" {
  display_name = "Syslog (TCP)"
}

data "nsxt_policy_context_profile" "cxt_dns" {
  display_name = "DNS"
}
