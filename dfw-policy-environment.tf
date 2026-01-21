resource "nsxt_policy_security_policy" "vcf_f_environment" {
  display_name = "VCF Fleet Environment"
  description  = "VCF Fleet Environment"
  category     = "Environment"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope              = [nsxt_policy_group.vcf_f.path]
  sequence_number = 1

  rule {
    display_name       = "Bastion to VCF Fleet"
    source_groups      = [nsxt_policy_group.bastion.path]
    destination_groups = [nsxt_policy_group.vcf_f.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.ssh.path,data.nsxt_policy_service.icmp_all.path,data.nsxt_policy_service.rdp.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "Tools to VCF Fleet"
    source_groups      = [nsxt_policy_group.tools.path]
    destination_groups = [nsxt_policy_group.vcf_f.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.ssh.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "VCF Automation Portal Access"
    destination_groups = [nsxt_policy_group.vcf_a.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "JUMP_TO_APPLICATION"
    logged             = false
  }

  rule {
    display_name       = "VCF01 Backup Traffic"
    source_groups      = [nsxt_policy_group.vcf_f.path]
    destination_groups = [nsxt_policy_group.backup_svc.path]
    services           = [data.nsxt_policy_service.ssh.path,data.nsxt_policy_service.ftp.path,data.nsxt_policy_service.icmp_all.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "VCF01 Mail Server Traffic"
    source_groups      = [nsxt_policy_group.vcf_f.path]
    destination_groups = [nsxt_policy_group.smtp_svc.path]
    services           = [data.nsxt_policy_service.smtp.path,data.nsxt_policy_service.smtp_tls.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "Broadcom Depot Traffic"
    source_groups      = [nsxt_policy_group.vcf_f.path]
    services           = [data.nsxt_policy_service.https.path]
    profiles           = [nsxt_policy_context_profile.internet_fqdns.path]
    action             = "ALLOW"
    logged             = false
  }
}

resource "nsxt_policy_security_policy" "vcf_fm_environment" {
  display_name = "VCF Fleet Management Environment"
  description  = "VCF Fleet Management Environment"
  category     = "Environment"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.vcf_fm.path]
  sequence_number = 2

  rule {
    display_name       = "VCF Fleet Management to VCF01 Instance"
    source_groups      = [nsxt_policy_group.vcf_fm.path]
    destination_groups = [nsxt_policy_group.vcf01_m01.path,nsxt_policy_group.vcf01_w01.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SDDC Manager to VCF01 Instance"
    source_groups      = [nsxt_policy_group.vcf01_sddc.path]
    destination_groups = [nsxt_policy_group.vcf01_m01.path,nsxt_policy_group.vcf01_w01.path]
    services           = [data.nsxt_policy_service.ssh.path,nsxt_policy_service.tcp_5480.path,data.nsxt_policy_service.icmp_echo.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "VCF OPS CP to VCF01 Instance"
    source_groups      = [nsxt_policy_group.vcf01_ops_cp.path]
    destination_groups = [nsxt_policy_group.vcf_fm.path,nsxt_policy_group.vcf01_m01.path,nsxt_policy_group.vcf01_w01.path]
    services           = [data.nsxt_policy_service.icmp_echo.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "W01 Supervisor to VCF OPS CP"
    source_groups      = [nsxt_policy_group.w01_sup01.path]
    destination_groups = [nsxt_policy_group.vcf01_ops_cp.path]
    services           = [nsxt_policy_service.tcp_8443.path]
    action             = "ALLOW"
    logged             = false
  }  
  
  rule {
    display_name       = "VCF01 to VCF Ops for Net"
    source_groups      = [nsxt_policy_group.vcf01_m01.path,nsxt_policy_group.vcf01_w01.path]
    destination_groups = [nsxt_policy_group.vcf01_ops_net_cn.path]
    services           = [data.nsxt_policy_service.https.path,nsxt_policy_service.tcp_1991.path,nsxt_policy_service.udp_2055.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "VCFA to W01 Supervisor"
    source_groups      = [nsxt_policy_group.vcf_a.path]
    destination_groups = [nsxt_policy_group.w01_sup01.path]
    services           = [nsxt_policy_service.tcp_6443.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "W01 Supervisor to VCFA"
    source_groups      = [nsxt_policy_group.w01_sup01.path]
    destination_groups = [nsxt_policy_group.vcf_a.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "VCF Fleet Management Intra-Environment"
    source_groups      = [nsxt_policy_group.vcf_fm.path]
    destination_groups = [nsxt_policy_group.vcf_fm.path]
    action             = "JUMP_TO_APPLICATION"
    logged             = false
  }  

  rule {
    display_name       = "Lock Down"
    action             = "DROP"
    logged             = true
    log_label          = "vcf_fm"
  }
}

resource "nsxt_policy_security_policy" "vcf01_m01_environment" {
  display_name = "VCF01 Management Domain Environment"
  description  = "VCF01 Management Domain Environment"
  category     = "Environment"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.vcf01_m01.path]
  sequence_number = 3

  rule {
    display_name       = "VCF Fleet Management to VCF01 Management Domain"
    source_groups      = [nsxt_policy_group.vcf_fm.path]
    destination_groups = [nsxt_policy_group.vcf01_m01.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SDDC Manager to VCF01 Management Domain"
    source_groups      = [nsxt_policy_group.vcf01_sddc.path]
    destination_groups = [nsxt_policy_group.vcf01_m01.path]
    services           = [data.nsxt_policy_service.ssh.path,nsxt_policy_service.tcp_5480.path,data.nsxt_policy_service.icmp_echo.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "VCF OPS CP to VCF01 Management Domain"
    source_groups      = [nsxt_policy_group.vcf01_ops_cp.path]
    destination_groups = [nsxt_policy_group.vcf01_m01.path]
    services           = [data.nsxt_policy_service.icmp_echo.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "VCF01 Management Domain to VCF Ops for Net"
    source_groups      = [nsxt_policy_group.vcf01_m01.path]
    destination_groups = [nsxt_policy_group.vcf01_ops_net_cn.path]
    services           = [data.nsxt_policy_service.https.path,nsxt_policy_service.tcp_1991.path,nsxt_policy_service.udp_2055.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "VCF01 Management Domain Intra-Environment"
    source_groups      = [nsxt_policy_group.vcf01_m01.path]
    destination_groups = [nsxt_policy_group.vcf01_m01.path]
    action             = "JUMP_TO_APPLICATION"
    logged             = false
  } 

  rule {
    display_name       = "Lock Down"
    action             = "DROP"
    logged             = true
    log_label          = "vcf_m01"
  }
}

resource "nsxt_policy_security_policy" "vcf01_w01_environment" {
  display_name = "VCF01 Workload Domain 01 Environment"
  description  = "VCF01 Workload Domain 01 Environment"
  category     = "Environment"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.vcf01_w01.path]
  sequence_number = 4

  rule {
    display_name       = "VCF Fleet Management to VCF01 Workload Domain 01"
    source_groups      = [nsxt_policy_group.vcf_fm.path]
    destination_groups = [nsxt_policy_group.vcf01_w01.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "SDDC Manager to VCF01 Workload Domain 01"
    source_groups      = [nsxt_policy_group.vcf01_sddc.path]
    destination_groups = [nsxt_policy_group.vcf01_w01.path]
    services           = [data.nsxt_policy_service.ssh.path,nsxt_policy_service.tcp_5480.path,data.nsxt_policy_service.icmp_echo.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "VCF OPS CP to VCF01 Workload Domain 01"
    source_groups      = [nsxt_policy_group.vcf01_ops_cp.path]
    destination_groups = [nsxt_policy_group.vcf01_w01.path]
    services           = [data.nsxt_policy_service.icmp_echo.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "VCF01 Workload Domain 01 to VCF Ops for Net"
    source_groups      = [nsxt_policy_group.vcf01_w01.path]
    destination_groups = [nsxt_policy_group.vcf01_ops_net_cn.path]
    services           = [data.nsxt_policy_service.https.path,nsxt_policy_service.tcp_1991.path,nsxt_policy_service.udp_2055.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "VCF01 Workload Domain 01 Intra-Environment"
    source_groups      = [nsxt_policy_group.vcf01_w01.path]
    destination_groups = [nsxt_policy_group.vcf01_w01.path]
    action             = "JUMP_TO_APPLICATION"
    logged             = false
  } 

  rule {
    display_name       = "Lock Down"
    action             = "DROP"
    logged             = true
    log_label          = "vcf_w01"
  }
}