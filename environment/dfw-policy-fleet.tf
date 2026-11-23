# Environment category policy for the whole fleet (sequence 1). The VCF Fleet Management policy
# (sequence 2) is in dfw-policy-fm.tf. The domain policies (sequence 3 and 4) are in
# dfw-policy-domains.tf; give any further workload domain the next free sequence number.
#
# An ALLOW rule here ends evaluation: the flow is not checked against the Application policies.
# JUMP_TO_APPLICATION skips the remaining Environment rules and hands the flow to Application.

resource "nsxt_policy_security_policy" "vcf_fleet_environment" {
  display_name    = "VCF Fleet"
  description     = "VCF Fleet"
  category        = "Environment"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["vcf_fleet"]]
  sequence_number = 1

  rule {
    display_name       = "Bastion Access"
    source_groups      = [var.group_paths["bastion"]]
    destination_groups = [var.group_paths["vcf_fleet"]]
    services           = [var.service_paths["https"], var.service_paths["ssh"], var.service_paths["icmp_all"], var.service_paths["rdp"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "Tools Access"
    source_groups      = [var.group_paths["tools"]]
    destination_groups = [var.group_paths["vcf_fleet"]]
    services           = [var.service_paths["https"], var.service_paths["ssh"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  # Syslog to the external collector (SYSLOG_SVC) is allowed in the Infrastructure category.
  rule {
    display_name       = "VCF Logging service"
    source_groups      = [var.group_paths["vcf_fleet"]]
    destination_groups = [var.group_paths["vcf01_msvc"]]
    services           = [var.service_paths["syslog_tcp"], var.service_paths["syslog_udp"], var.service_paths["tcp_1514"], var.service_paths["tcp_9543"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name       = "Backup"
    source_groups      = [var.group_paths["vcf_fleet"]]
    destination_groups = [var.group_paths["vcf01_sddc"], var.group_paths["backup_svc"]]
    services           = [var.service_paths["ssh"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name       = "E-Mail"
    source_groups      = [var.group_paths["vcf_fleet"]]
    destination_groups = [var.group_paths["smtp_svc"]]
    services           = [var.service_paths["smtp"], var.service_paths["smtp_tls"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name  = "Broadcom Depot"
    source_groups = [var.group_paths["vcf_fleet"]]
    services      = [var.service_paths["https"]]
    profiles      = [var.context_profile_paths["internet_fqdns"]]
    action        = "ALLOW"
    ip_version    = "IPV4"
    direction     = "OUT"
    logged        = false
  }

  rule {
    display_name       = "VCF Automation Portal Access"
    destination_groups = [var.group_paths["vcf_a_lb"]]
    services           = [var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }
}
