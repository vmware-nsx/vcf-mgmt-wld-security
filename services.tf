data "nsxt_policy_service" "icmp_all" {
  display_name = "ICMP ALL"
}

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

data "nsxt_policy_service" "https" {
  display_name = "HTTPS"
}

data "nsxt_policy_service" "http" {
  display_name = "HTTP"
}

data "nsxt_policy_service" "ldap" {
  display_name = "LDAP"
}

data "nsxt_policy_service" "ldap_udp" {
  display_name = "LDAP-UDP"
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

data "nsxt_policy_service" "syslog_tcp" {
  display_name = "Syslog (TCP)"
}

data "nsxt_policy_service" "snmp" {
  display_name = "SNMP"
}

data "nsxt_policy_service" "ntp" {
  display_name = "NTP"
}

data "nsxt_policy_service" "rdp" {
  display_name = "RDP"
}

data "nsxt_policy_service" "update_manager" {
  display_name = "Update Manager"
}

#data "nsxt_policy_service" "tcp_902" {
#  display_name = "VMware-ESXi5.x-TCP"
#}

data "nsxt_policy_service" "udp_902" {
  display_name = "VMware-ESXi5.x-UDP"
}

#data "nsxt_policy_service" "tcp_9000_9100" {
#  display_name = "VMware-UpdateMgr"
#}

data "nsxt_policy_service" "tcp_9087" {
  display_name = "Vmware-UpdateMgr-update"
}

data "nsxt_policy_service" "tcp_9084" {
  display_name = "VMware-UpdateMgr-VUM"
}

data "nsxt_policy_service" "ftp" {
  display_name = "FTP"
}

data "nsxt_policy_service" "smtp" {
  display_name = "SMTP"
}

data "nsxt_policy_service" "smtp_tls" {
  display_name = "SMTP_TLS"
}

data "nsxt_policy_context_profile" "cxt_activdir" {
  display_name = "ACTIVDIR"
}

data "nsxt_policy_context_profile" "cxt_ldap" {
  display_name = "LDAP"
}

data "nsxt_policy_context_profile" "cxt_dns" {
  display_name = "DNS"
}

data "nsxt_policy_context_profile" "cxt_ssl" {
  display_name = "SSL"
}

data "nsxt_policy_context_profile" "cxt_dcerpc" {
  display_name = "DCERPC"
}

data "nsxt_policy_context_profile" "cxt_ssh" {
  display_name = "SSH"
}

resource "nsxt_policy_service" "tcp_2012_2020" {
  description  = "ELM ports service provisioned by Terraform"
  display_name = "TCP-2012_2020"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["2012", "2020"]
  }
}

resource "nsxt_policy_service" "tcp_5480" {
  description  = "Workload Domain Deployment"
  display_name = "TCP-5480"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["5480"]
  }
}

resource "nsxt_policy_service" "tcp_6500" {
  description  = "ESXi Dump Collector"
  display_name = "TCP-6500"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["6500"]
  }
}

resource "nsxt_policy_service" "tcp_6501_6502" {
  description  = "Auto Deploy"
  display_name = "TCP-6501_6502"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["6501","6502"]
  }
}

resource "nsxt_policy_service" "tcp_7475_7476" {
  description  = "VMware vSphere Authentication Proxy"
  display_name = "TCP-7475_7476"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["7475","7476"]
  }
}

resource "nsxt_policy_service" "tcp_1234_1235" {
  description  = "NSX messaging"
  display_name = "TCP-1234_1235"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["1234","1235"]
  }
}

resource "nsxt_policy_service" "tcp_5671" {
  description  = "NSX messaging"
  display_name = "TCP-5671"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["5671"]
  }
}

resource "nsxt_policy_service" "tcp_9040" {
  description  = "NSX Distributed Datastore"
  display_name = "TCP-9040"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["9040"]
  }
}

resource "nsxt_policy_service" "tcp_9000" {
  description  = "NSX Distributed Datastore"
  display_name = "TCP-9000"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["9000"]
  }
}

resource "nsxt_policy_service" "tcp_5432" {
  description  = "vCenter RDU"
  display_name = "TCP-5432"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["5432"]
  }
}

resource "nsxt_policy_service" "tcp_8443" {
  description  = "Aria Suite LCM"
  display_name = "TCP-8443"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["8443"]
  }
}

resource "nsxt_policy_service" "tcp_9543" {
  description  = "Aria Suite LCM"
  display_name = "TCP-9543"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["9543"]
  }
}

resource "nsxt_policy_service" "tcp_16520" {
  description  = "Aria Suite LCM"
  display_name = "TCP-16520"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["16520"]
  }
}

resource "nsxt_policy_service" "tcp_1514" {
  description  = "Aria Operations for Logs"
  display_name = "TCP-1514"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["1514"]
  }
}

resource "nsxt_policy_service" "tcp_6514" {
  description  = "Aria Operations for Logs"
  display_name = "TCP-6514"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["6514"]
  }
}

resource "nsxt_policy_service" "tcp_6443" {
  description  = "Kubernetes API"
  display_name = "TCP-6443"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["6443"]
  }
}

resource "nsxt_policy_service" "tcp_5000" {
  description  = "vSphere Supervizor"
  display_name = "TCP-5000"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["5000"]
  }
}

resource "nsxt_policy_service" "tcp_9092" {
  description  = "SSP Messaging"
  display_name = "TCP-9092"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["9092"]
  }
}

resource "nsxt_policy_context_profile_custom_attribute" "custom_fqdn1" {
  key       = "DOMAIN_NAME"
  attribute = "*.broadcom.com"
}

resource "nsxt_policy_context_profile_custom_attribute" "custom_fqdn2" {
  key       = "DOMAIN_NAME"
  attribute = "*.vmware.com"
}

resource "nsxt_policy_context_profile" "internet_fqdns" {
  display_name = "INTERNET_FQDNS"
  description  = "VCF upgrade and patch binaries"
  domain_name {
     value       = ["*.broadcom.com", "*.vmware.com"]
  }
  depends_on = [nsxt_policy_context_profile_custom_attribute.custom_fqdn1,nsxt_policy_context_profile_custom_attribute.custom_fqdn2]
}
