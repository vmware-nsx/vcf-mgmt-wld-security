resource "nsxt_policy_group" "smtp_svc" {
  nsx_id       = "SMTP_SVC"
  display_name = "SMTP_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.external_services.smtp_server]
    }
  }
}

resource "nsxt_policy_group" "bastion" {
  nsx_id       = "BASTION"
  display_name = "BASTION"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.external_services.bastion_host]
    }
  }
}

resource "nsxt_policy_group" "tools" {
  nsx_id       = "TOOLS"
  display_name = "TOOLS"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.external_services.tools_server]
    }
  }
}

resource "nsxt_policy_group" "backup_svc" {
  nsx_id       = "BACKUP_SVC"
  display_name = "BACKUP_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.external_services.backup_server]
    }
  }
}

# External syslog collector. Optional: created only when external_services.syslog_server is set.
resource "nsxt_policy_group" "syslog_svc" {
  count = var.external_services.syslog_server != null ? 1 : 0

  nsx_id       = "SYSLOG_SVC"
  display_name = "SYSLOG_SVC"
  group_type   = "IPAddress"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.external_services.syslog_server]
    }
  }
}
