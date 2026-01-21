resource "nsxt_policy_security_policy" "vcfops_policy" {
  display_name = "VCF Operations Policy"
  description  = "VCF Operations Policy"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.vcf_ops.path,nsxt_policy_group.vcf_ops_fm.path,nsxt_policy_group.vcf01_ops_cp.path,nsxt_policy_group.vcf01_sddc.path]
  sequence_number = 1

  rule {
    display_name       = "VCF Ops HTTPS"
    source_groups      = [nsxt_policy_group.vcf_ops.path,nsxt_policy_group.vcf_ops_fm.path,nsxt_policy_group.vcf01_ops_cp.path,nsxt_policy_group.vcf01_sddc.path]
    destination_groups = [nsxt_policy_group.vcf_ops.path,nsxt_policy_group.vcf_ops_fm.path,nsxt_policy_group.vcf01_ops_cp.path,nsxt_policy_group.vcf01_sddc.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "VCF Ops to VCFA, VCFOPS_LOGS and VCFOPS_NET"
    source_groups      = [nsxt_policy_group.vcf_ops.path]
    destination_groups = [nsxt_policy_group.vcf_a.path,nsxt_policy_group.vcf_ops_logs.path,nsxt_policy_group.vcf_ops_net.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "VCF Ops for Logs to  VCF Ops"
    source_groups      = [nsxt_policy_group.vcf_ops_logs.path]
    destination_groups = [nsxt_policy_group.vcf_ops.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "VCF Ops Fleet Management to VCFA"
    source_groups      = [nsxt_policy_group.vcf_ops_fm.path]
    destination_groups = [nsxt_policy_group.vcf_a.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.ssh.path,nsxt_policy_service.tcp_6443.path,nsxt_policy_service.tcp_30000_30005.path]
    action             = "ALLOW"
    logged             = false
  }
  
  rule {
    display_name       = "VCF Operations Lock Down"
    action             = "DROP"
    logged             = true
    log_label          = "vcf_ops"
  }
}

resource "nsxt_policy_security_policy" "vcfops_logs_policy" {
  display_name = "VCF Operations for Logs Policy"
  description  = "VCF Operations for Logs Policy"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.vcf_ops_logs.path]
  sequence_number = 2

  rule {
    display_name       = "VCF Ops VCFOPS_LOGS"
    source_groups      = [nsxt_policy_group.vcf_ops.path,nsxt_policy_group.vcf_ops_logs.path]
    destination_groups = [nsxt_policy_group.vcf_ops.path,nsxt_policy_group.vcf_ops_logs.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "VCF Operations for Logs Lock Down"
    action             = "DROP"
    logged             = true
    log_label          = "vcf_ops_logs"
  }
}

resource "nsxt_policy_security_policy" "vcfops_net_policy" {
  display_name = "VCF Operations for Networks Policy"
  description  = "VCF Operations for Networks Policy"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.vcf01_ops_net_cn.path,nsxt_policy_group.vcf_ops_net.path]
  sequence_number = 3

  rule {
    display_name       = "VCF Ops to VCFA and VCFOPS_LOGS"
    source_groups      = [nsxt_policy_group.vcf_ops.path]
    destination_groups = [nsxt_policy_group.vcf_ops_net.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "VCF Ops for Net Collector to VCF Ops for Net"
    source_groups      = [nsxt_policy_group.vcf01_ops_net_cn.path]
    destination_groups = [nsxt_policy_group.vcf_ops_net.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "VCF Operations for Networks Lock Down"
    action             = "DROP"
    logged             = true
    log_label          = "vcf_ops_net"
  }
}

resource "nsxt_policy_security_policy" "vcfa_policy" {
  display_name = "VCF Automation Policy"
  description  = "VCF Automation Policy"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = true
  scope        = [nsxt_policy_group.vcf_a.path]
  sequence_number = 4
  
  rule {
    display_name       = "VCF Ops to VCFA"
    source_groups      = [nsxt_policy_group.vcf_ops.path]
    destination_groups = [nsxt_policy_group.vcf_a.path]
    services           = [data.nsxt_policy_service.https.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "VCF Ops Fleet Management to VCFA"
    source_groups      = [nsxt_policy_group.vcf_ops_fm.path]
    destination_groups = [nsxt_policy_group.vcf_a.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.ssh.path,nsxt_policy_service.tcp_6443.path,nsxt_policy_service.tcp_30000_30005.path]
    action             = "ALLOW"
    logged             = false
  }
rule {
    display_name       = "VCF Automation Cloud User Access"
    destination_groups = [nsxt_policy_group.vcf_a_lb.path]
    services           = [data.nsxt_policy_service.https.path]
    profiles           = [data.nsxt_policy_context_profile.cxt_ssl.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "VCF Automation Lock Down"
    action             = "DROP"
    logged             = true
    log_label          = "vcfa"
  }
}