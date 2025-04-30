resource "nsxt_policy_security_policy" "vcf_aria" {
  display_name = "VCF01 Aria Suite Policy"
  description  = "Control Aria Suite traffic"
  category     = "Environment"
  locked       = false
  stateful     = true
  tcp_strict   = true
  sequence_number = 2

  rule {
    display_name       = "Aria Suite Internal Traffic"
    source_groups      = [nsxt_policy_group.aria_suite.path]
    destination_groups = [nsxt_policy_group.aria_suite.path]
    scope              = [nsxt_policy_group.aria_suite.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "Aria Suite Inbound Traffic"
    source_groups      = [nsxt_policy_group.m01_wld.path]
    destination_groups = [nsxt_policy_group.aria_suite.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.ssh.path,data.nsxt_policy_service.syslog_udp.path,data.nsxt_policy_service.syslog_tcp.path,nsxt_policy_service.tcp_9000.path,nsxt_policy_service.tcp_9543.path,nsxt_policy_service.tcp_1514.path,nsxt_policy_service.tcp_6514.path]
    scope              = [nsxt_policy_group.vcf01.path]
    action             = "ALLOW"
    logged             = false
  }
    
  rule {
    display_name       = "Aria Suite Outbound Traffic"
    source_groups      = [nsxt_policy_group.aria_suite.path]
    services           = [data.nsxt_policy_service.icmp_all.path,data.nsxt_policy_service.https.path,data.nsxt_policy_service.ssh.path,data.nsxt_policy_service.snmp.path,data.nsxt_policy_service.syslog_udp.path,data.nsxt_policy_service.syslog_tcp.path,nsxt_policy_service.tcp_9000.path,nsxt_policy_service.tcp_9543.path]
    scope              = [nsxt_policy_group.vcf01.path]
    action             = "ALLOW"
    logged             = false
  }

  rule {
    display_name       = "Aria Suite Default Drop"
    scope              = [nsxt_policy_group.aria_suite.path]
    action             = "DROP"
    logged             = true
    log_label          = "aria_suite"
  }
}
