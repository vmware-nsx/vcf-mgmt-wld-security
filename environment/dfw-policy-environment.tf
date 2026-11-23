# Environment category policies for the whole fleet (sequence 1) and for VCF Fleet Management
# (sequence 2). The domain policies (sequence 3 and 4) are in dfw-policy-environment-domains.tf; give
# any further workload domain the next free sequence number.
#
# An ALLOW rule here ends evaluation: the flow is not checked against the Application policies.
# JUMP_TO_APPLICATION skips the remaining Environment rules and hands the flow to Application.

resource "nsxt_policy_security_policy" "vcf_fleet_environment" {
  display_name    = "VCF Fleet External"
  description     = "VCF Fleet Environment"
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

resource "nsxt_policy_security_policy" "vcf_fm_environment" {
  display_name    = "VCF Fleet Management"
  description     = "VCF Fleet Management Environment"
  category        = "Environment"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["vcf_fm"]]
  sequence_number = 2

  rule {
    display_name       = "VCF Fleet Management (Intra)"
    source_groups      = [var.group_paths["vcf_fm"]]
    destination_groups = [var.group_paths["vcf_fm"]]
    action             = "JUMP_TO_APPLICATION"
    ip_version         = "IPV4"
    logged             = false
  }

  rule {
    display_name       = "VCF Fleet Management to VCF01 Instance"
    source_groups      = [var.group_paths["vcf_fm"]]
    destination_groups = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    services           = [var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "SDDC Manager to VCF01 Instance"
    source_groups      = [var.group_paths["vcf01_sddc"]]
    destination_groups = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    services           = [var.service_paths["ssh"], var.service_paths["tcp_5480"], var.service_paths["icmp_echo"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "VCF OPS CP to VCF01 Instance"
    source_groups      = [var.group_paths["vcf01_ops_cp"]]
    destination_groups = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    services           = [var.service_paths["icmp_echo"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "VCF01 Instance to VCF Management Services"
    source_groups      = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    destination_groups = [var.group_paths["vcf01_msvc"]]
    services           = [var.service_paths["https"], var.service_paths["tcp_4505_4506"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "Workload Domain Supervisor to VCF OPS CP"
    source_groups      = [var.group_paths["w01_sup01"]]
    destination_groups = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_ops_cp"]]
    services           = [var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "VCF01 Instance to VCF Ops for Net"
    source_groups      = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    destination_groups = [var.group_paths["vcf01_ops_net_cn"]]
    services           = [var.service_paths["https"], var.service_paths["tcp_1991"], var.service_paths["udp_2055"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "Components Backup on the SDDC Manager"
    source_groups      = [var.group_paths["m01_nsx"], var.group_paths["w01_nsx"], var.group_paths["m01_avi"]]
    destination_groups = [var.group_paths["vcf01_sddc"]]
    services           = [var.service_paths["ssh"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "VCFA to Workload Domain Supervisor"
    source_groups      = [var.group_paths["vcf_a"]]
    destination_groups = [var.group_paths["w01_sup01"]]
    services           = [var.service_paths["tcp_6443"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "Workload Domain Supervisor to VCFA"
    source_groups      = [var.group_paths["w01_sup01"]]
    destination_groups = [var.group_paths["vcf_a"]]
    services           = [var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "vCenter Servers to VCF License Server"
    source_groups      = [var.group_paths["m01_vc"], var.group_paths["w01_vc"]]
    destination_groups = [var.group_paths["vcf_lic"]]
    services           = [var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "vDefend License Hub to Endpoints"
    source_groups      = [var.group_paths["vcf_lhub"]]
    destination_groups = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    services           = [var.service_paths["tcp_2049"], var.service_paths["tcp_3260"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "Endpoints to vDefend License Hub"
    source_groups      = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    destination_groups = [var.group_paths["vcf_lhub"]]
    services           = [var.service_paths["https"], var.service_paths["tcp_9092"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "SSPI to VCF01 Instance"
    source_groups      = [var.group_paths["vcf01_sspi"]]
    destination_groups = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    services           = [var.service_paths["tcp_6443"], var.service_paths["ssh"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "VCF01 Instance to SSPI"
    source_groups      = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    destination_groups = [var.group_paths["vcf01_sspi"]]
    services           = [var.service_paths["https"]]
    action             = "ALLOW"
    ip_version         = "IPV4"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name = "Fleet Management (Lock Down)"
    action       = "DROP"
    ip_version   = "IPV4"
    logged       = true
    log_label    = "vcf_fm"
  }
}
