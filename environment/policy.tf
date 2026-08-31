resource "nsxt_policy_security_policy" "vcf_f_environment" {
  display_name    = "VCF Fleet Environment"
  description     = "VCF Fleet Environment"
  category        = "Environment"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["vcf_f"]]
  sequence_number = 1

  rule {
    display_name       = "Bastion to VCF Fleet"
    source_groups      = [var.group_paths["bastion"]]
    destination_groups = [var.group_paths["vcf_f"]]
    services           = [data.nsxt_policy_service.https.path, data.nsxt_policy_service.ssh.path, data.nsxt_policy_service.icmp_all.path, data.nsxt_policy_service.rdp.path]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "Tools to VCF Fleet"
    source_groups      = [var.group_paths["tools"]]
    destination_groups = [var.group_paths["vcf_f"]]
    services           = [data.nsxt_policy_service.https.path, data.nsxt_policy_service.ssh.path]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "VCF Automation Portal Access"
    destination_groups = [var.group_paths["vcf_a"]]
    services           = [data.nsxt_policy_service.https.path]
    action             = "JUMP_TO_APPLICATION"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "VCF01 Backup Traffic"
    source_groups      = [var.group_paths["vcf_f"]]
    destination_groups = [var.group_paths["backup_svc"]]
    services           = [data.nsxt_policy_service.ssh.path, data.nsxt_policy_service.ftp.path, data.nsxt_policy_service.icmp_all.path]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "VCF01 Mail Server Traffic"
    source_groups      = [var.group_paths["vcf_f"]]
    destination_groups = [var.group_paths["smtp_svc"]]
    services           = [data.nsxt_policy_service.smtp.path, data.nsxt_policy_service.smtp_tls.path]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "Broadcom Depot Traffic"
    source_groups      = [var.group_paths["vcf_f"]]
    services           = [data.nsxt_policy_service.https.path]
    profiles           = [var.context_profile_paths["internet_fqdns"]]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }
}

resource "nsxt_policy_security_policy" "vcf_fm_environment" {
  display_name    = "VCF Fleet Management Environment"
  description     = "VCF Fleet Management Environment"
  category        = "Environment"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["vcf_fm"]]
  sequence_number = 2

  rule {
    display_name       = "VCF Fleet Management Intra-Environment"
    source_groups      = [var.group_paths["vcf_fm"]]
    destination_groups = [var.group_paths["vcf_fm"]]
    action             = "JUMP_TO_APPLICATION"
    logged             = false
  }

  rule {
    display_name       = "VCF Fleet Management to VCF01 Instance"
    source_groups      = [var.group_paths["vcf_fm"]]
    destination_groups = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "SDDC Manager to VCF01 Instance"
    source_groups      = [var.group_paths["vcf01_sddc"]]
    destination_groups = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    services           = [data.nsxt_policy_service.ssh.path, local.tcp_5480, data.nsxt_policy_service.icmp_echo.path]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "VCF OPS CP to VCF01 Instance"
    source_groups      = [var.group_paths["vcf01_ops_cp"]]
    destination_groups = [var.group_paths["vcf_fm"], var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    services           = [data.nsxt_policy_service.icmp_echo.path]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "VCF01 Instance to VCF Management Services"
    source_groups      = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    destination_groups = [var.group_paths["vcf01_msvc"]]
    services           = [data.nsxt_policy_service.https.path, local.tcp_4505_4506, local.tcp_1514, local.tcp_9543]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "W01 Supervisor to VCF OPS CP"
    source_groups      = [var.group_paths["w01_sup01"]]
    destination_groups = [var.group_paths["vcf01_ops_cp"]]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "VCF01 to VCF Ops for Net"
    source_groups      = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    destination_groups = [var.group_paths["vcf01_ops_net_cn"]]
    services           = [data.nsxt_policy_service.https.path, local.tcp_1991, local.udp_2055]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "Components Backup on the SDDC Manager"
    source_groups      = [var.group_paths["m01_nsx"],var.group_paths["w01_nsx"],var.group_paths["m01_avi"]]
    destination_groups = [var.group_paths["vcf01_sddc"]]
    services           = [data.nsxt_policy_service.ssh.path]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "VCFA to W01 Supervisor"
    source_groups      = [var.group_paths["vcf_a"]]
    destination_groups = [var.group_paths["w01_sup01"]]
    services           = [local.tcp_6443]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "W01 Supervisor to VCFA"
    source_groups      = [var.group_paths["w01_sup01"]]
    destination_groups = [var.group_paths["vcf_a"]]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "vCenter Servers to VCF License Server"
    source_groups      = [var.group_paths["m01_vc"], var.group_paths["w01_vc"]]
    destination_groups = [var.group_paths["vcf_lic"]]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "vDefend License Hub to Endpoints"
    source_groups      = [var.group_paths["vcf_lhub"]]
    destination_groups = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    services           = [data.nsxt_policy_service.https.path, local.tcp_3260, local.tcp_2049]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "Endpoints to vDefend License Hub"
    source_groups      = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    destination_groups = [var.group_paths["vcf_lhub"]]
    services           = [data.nsxt_policy_service.https.path, local.tcp_9092]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "SSPI to vCenter Servers"
    source_groups      = [var.group_paths["vcf01_sspi"]]
    destination_groups = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    services           = [data.nsxt_policy_service.https.path, local.tcp_6443]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "vCenter Servers to SSPI Registry"
    source_groups      = [var.group_paths["vcf01_m01"], var.group_paths["vcf01_w01"]]
    destination_groups = [var.group_paths["vcf01_sspi"]]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "Lock Down"
    action             = "DROP"
    ip_version         = "IPV4"
    logged             = true
    log_label          = "vcf_fm"
  }
}

resource "nsxt_policy_security_policy" "vcf01_m01_environment" {
  display_name    = "VCF01 Management Domain Environment"
  description     = "VCF01 Management Domain Environment"
  category        = "Environment"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["vcf01_m01"]]
  sequence_number = 3

  rule {
    display_name       = "VCF01 Management Domain Intra-Environment"
    source_groups      = [var.group_paths["vcf01_m01"]]
    destination_groups = [var.group_paths["vcf01_m01"]]
    action             = "JUMP_TO_APPLICATION"
    logged             = false
  }

  rule {
    display_name       = "VCF Fleet Management to VCF01 Management Domain"
    source_groups      = [var.group_paths["vcf_fm"]]
    destination_groups = [var.group_paths["vcf01_m01"]]
    services           = [data.nsxt_policy_service.https.path]
    direction          = "IN"
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SDDC Manager to VCF01 Management Domain"
    source_groups      = [var.group_paths["vcf01_sddc"]]
    destination_groups = [var.group_paths["vcf01_m01"]]
    services           = [data.nsxt_policy_service.ssh.path, local.tcp_5480, data.nsxt_policy_service.icmp_echo.path]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "Components Backup on the SDDC Manager"
    source_groups      = [var.group_paths["m01_nsx"],var.group_paths["m01_avi"]]
    destination_groups = [var.group_paths["vcf01_sddc"]]
    services           = [data.nsxt_policy_service.ssh.path]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "VCF OPS CP to VCF01 Management Domain"
    source_groups      = [var.group_paths["vcf01_ops_cp"]]
    destination_groups = [var.group_paths["vcf01_m01"]]
    services           = [data.nsxt_policy_service.icmp_echo.path]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "VCF01 Management Domain to VCF Management Services"
    source_groups      = [var.group_paths["vcf01_m01"]]
    destination_groups = [var.group_paths["vcf01_msvc"]]
    services           = [data.nsxt_policy_service.https.path, local.tcp_4505_4506, local.tcp_1514, local.tcp_9543]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "VCF01 Management Domain to VCF Ops for Net"
    source_groups      = [var.group_paths["vcf01_m01"]]
    destination_groups = [var.group_paths["vcf01_ops_net_cn"]]
    services           = [data.nsxt_policy_service.https.path, local.tcp_1991, local.udp_2055]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "Management Domain vCenter Server to VCF License Server"
    source_groups      = [var.group_paths["m01_vc"]]
    destination_groups = [var.group_paths["vcf_lic"]]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "vDefend License Hub to Endpoints"
    source_groups      = [var.group_paths["vcf_lhub"]]
    destination_groups = [var.group_paths["vcf01_m01"]]
    services           = [data.nsxt_policy_service.https.path, local.tcp_3260, local.tcp_2049]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "Endpoints to vDefend License Hub"
    source_groups      = [var.group_paths["vcf01_m01"]]
    destination_groups = [var.group_paths["vcf_lhub"]]
    services           = [data.nsxt_policy_service.https.path, local.tcp_9092]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "Lock Down"
    action             = "DROP"
    ip_version         = "IPV4"
    logged             = true
    log_label          = "vcf_m01"
  }
}

resource "nsxt_policy_security_policy" "vcf01_w01_environment" {
  display_name    = "VCF01 Workload Domain 01 Environment"
  description     = "VCF01 Workload Domain 01 Environment"
  category        = "Environment"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [var.group_paths["vcf01_w01"]]
  sequence_number = 4

  rule {
    display_name       = "VCF01 Workload Domain 01 Intra-Environment"
    source_groups      = [var.group_paths["vcf01_w01"]]
    destination_groups = [var.group_paths["vcf01_w01"]]
    action             = "JUMP_TO_APPLICATION"
    logged             = false
  }

  rule {
    display_name       = "VCF Fleet Management to VCF01 Workload Domain 01"
    source_groups      = [var.group_paths["vcf_fm"]]
    destination_groups = [var.group_paths["vcf01_w01"]]
    services           = [data.nsxt_policy_service.https.path]
    direction          = "IN"
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SDDC Manager to VCF01 Workload Domain 01"
    source_groups      = [var.group_paths["vcf01_sddc"]]
    destination_groups = [var.group_paths["vcf01_w01"]]
    services           = [data.nsxt_policy_service.ssh.path, local.tcp_5480, data.nsxt_policy_service.icmp_echo.path]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "Components Backup on the SDDC Manager"
    source_groups      = [var.group_paths["w01_nsx"]]
    destination_groups = [var.group_paths["vcf01_sddc"]]
    services           = [data.nsxt_policy_service.ssh.path]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "VCF OPS CP to VCF01 Workload Domain 01"
    source_groups      = [var.group_paths["vcf01_ops_cp"]]
    destination_groups = [var.group_paths["vcf01_w01"]]
    services           = [data.nsxt_policy_service.icmp_echo.path]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "VCF01 Workload Domain to VCF Management Services"
    source_groups      = [var.group_paths["vcf01_w01"]]
    destination_groups = [var.group_paths["vcf01_msvc"]]
    services           = [data.nsxt_policy_service.https.path, local.tcp_4505_4506, local.tcp_1514, local.tcp_9543]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "VCF01 Workload Domain 01 to VCF Ops for Net"
    source_groups      = [var.group_paths["vcf01_w01"]]
    destination_groups = [var.group_paths["vcf01_ops_net_cn"]]
    services           = [data.nsxt_policy_service.https.path, local.tcp_1991, local.udp_2055]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "Workload Domain vCenter Server to VCF License Server"
    source_groups      = [var.group_paths["w01_vc"]]
    destination_groups = [var.group_paths["vcf_lic"]]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "vDefend License Hub to Endpoints"
    source_groups      = [var.group_paths["vcf_lhub"]]
    destination_groups = [var.group_paths["vcf01_w01"]]
    services           = [data.nsxt_policy_service.https.path, local.tcp_3260, local.tcp_2049]
    action             = "ALLOW"
    direction          = "IN"
    logged             = false
  }

  rule {
    display_name       = "Endpoints to vDefend License Hub"
    source_groups      = [var.group_paths["vcf01_w01"]]
    destination_groups = [var.group_paths["vcf_lhub"]]
    services           = [data.nsxt_policy_service.https.path, local.tcp_9092]
    action             = "ALLOW"
    direction          = "OUT"
    logged             = false
  }

  rule {
    display_name       = "Lock Down"
    action             = "DROP"
    ip_version         = "IPV4"
    logged             = true
    log_label          = "vcf_w01"
  }
}