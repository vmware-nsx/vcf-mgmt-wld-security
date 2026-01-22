resource "nsxt_policy_group" "dns_svc" {
  nsx_id       = "DNS_SVC"
  display_name = "DNS_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.dns_server]
    }
  }
}

resource "nsxt_policy_group" "ntp_svc" {
  nsx_id       = "NTP_SVC"
  display_name = "NTP_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.ntp_server]
    }
  }
}

resource "nsxt_policy_group" "dhcp_svc" {
  nsx_id       = "DHCP_SVC"
  display_name = "DHCP_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.dhcp_server]
    }
  }
}

resource "nsxt_policy_group" "ad_svc" {
  nsx_id       = "AD_SVC"
  display_name = "AD_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.ad_server]
    }
  }
}

resource "nsxt_policy_group" "smtp_svc" {
  nsx_id       = "SMTP_SVC"
  display_name = "SMTP_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.smtp_server]
    }
  }
}

resource "nsxt_policy_group" "bastion" {
  nsx_id       = "BASTION"
  display_name = "BASTION"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.bastion_host]
    }
  }
}

resource "nsxt_policy_group" "tools" {
  nsx_id       = "TOOLS"
  display_name = "TOOLS"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.tools_server]
    }
  }
}

resource "nsxt_policy_group" "backup_svc" {
  nsx_id       = "BACKUP_SVC"
  display_name = "BACKUP_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.backup_server]
    }
  }
}

resource "nsxt_policy_group" "siem_svc" {
  nsx_id       = "SIEM_SVC"
  display_name = "SIEM_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.siem_server]
    }
  }
}
