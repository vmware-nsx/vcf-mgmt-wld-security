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
    destination_ports = ["6501", "6502"]
  }
}

resource "nsxt_policy_service" "tcp_7475_7476" {
  description  = "VMware vSphere Authentication Proxy"
  display_name = "TCP-7475_7476"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["7475", "7476"]
  }
}

resource "nsxt_policy_service" "tcp_1234_1235" {
  description  = "NSX messaging"
  display_name = "TCP-1234_1235"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["1234", "1235"]
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

resource "nsxt_policy_service" "tcp_1514" {
  description  = "Aria Operations for Logs"
  display_name = "TCP-1514"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["1514"]
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

resource "nsxt_policy_service" "tcp_9092" {
  description  = "SSP Messaging"
  display_name = "TCP-9092"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["9092"]
  }
}

resource "nsxt_policy_service" "tcp_3260" {
  description  = "iSCSI"
  display_name = "TCP-3260"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["3260"]
  }
}

resource "nsxt_policy_service" "tcp_2049" {
  description  = "NFS"
  display_name = "TCP-2049"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["2049"]
  }
}

resource "nsxt_policy_service" "tcp_30000_30005" {
  description  = "VCF Ops LCM"
  display_name = "TCP-30000_30005"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["30000-30005"]
  }
}

resource "nsxt_policy_service" "tcp_1991" {
  description  = "VCF Operations for Networks tcp-1991"
  display_name = "TCP-1991"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["1991"]
  }
}

resource "nsxt_policy_service" "udp_2055" {
  description  = "VCF Operations for Networks udp-2055"
  display_name = "UDP-2055"

  l4_port_set_entry {
    protocol          = "UDP"
    destination_ports = ["2055"]
  }
}

resource "nsxt_policy_service" "tcp_1443" {
  description  = "IOFilterVP service"
  display_name = "TCP-1443"

  l4_port_set_entry {
    protocol          = "TCP"
    destination_ports = ["1443"]
  }
}

resource "nsxt_policy_service" "tcp_4505_4506" {
  nsx_id       = "TCP-4505_4506"
  display_name = "TCP-4505_4506"

  l4_port_set_entry {
    display_name      = "TCP-4505_4506"
    protocol          = "TCP"
    destination_ports = ["4505-4506"]
  }

  # nsx_id forces replacement. NSX refuses to delete a service that rules
  # still reference, so create the new one first and let the rules move to it.
  lifecycle {
    create_before_destroy = true
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

resource "nsxt_policy_context_profile_custom_attribute" "custom_fqdn3" {
  key       = "DOMAIN_NAME"
  attribute = "*.broadcom.net"
}

# NSX removes a context profile asynchronously and refuses to delete the custom FQDN attributes
# while it still lists the profile as a user (error 521033). On destroy, Terraform deletes the
# profile first, waits here, and only then deletes the attributes. Creation is not delayed.
resource "time_sleep" "context_profile_destroy_delay" {
  destroy_duration = "30s"

  depends_on = [
    nsxt_policy_context_profile_custom_attribute.custom_fqdn1,
    nsxt_policy_context_profile_custom_attribute.custom_fqdn2,
    nsxt_policy_context_profile_custom_attribute.custom_fqdn3,
  ]
}

resource "nsxt_policy_context_profile" "internet_fqdns" {
  display_name = "INTERNET_FQDNS"
  description  = "VCF upgrade and patch binaries"
  domain_name {
    value = ["*.broadcom.com", "*.vmware.com", "*.broadcom.net"]
  }
  depends_on = [time_sleep.context_profile_destroy_delay]
}
