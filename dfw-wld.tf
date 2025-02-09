resource "nsxt_policy_security_policy" "w01_policy" {
  display_name = "VI workload domain 01 policy"
  description  = "Control VI workload domain traffic"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = true

  rule {
    display_name       = "vCenter to Hosts"
    source_groups      = [nsxt_policy_group.w01_vc.path]
    destination_groups = [nsxt_policy_group.w01_hosts.path]
    services           = [data.nsxt_policy_service.update_manager.path,data.nsxt_policy_service.icmp_all.path]
    action             = "ALLOW"
    scope              = [nsxt_policy_group.w01_vc.path,]
    logged             = false
  }

  rule {
    display_name       = "Hosts to vCenter"
    source_groups      = [nsxt_policy_group.w01_hosts.path]
    destination_groups = [nsxt_policy_group.w01_vc.path]
    services           = [data.nsxt_policy_service.https.path,data.nsxt_policy_service.tcp_9087.path,data.nsxt_policy_service.tcp_9084.path,data.nsxt_policy_service.udp_902.path,nsxt_policy_service.tcp_6500.path,nsxt_policy_service.tcp_6501_6502.path,nsxt_policy_service.tcp_7475_7476.path]
    action             = "ALLOW"
    scope              = [nsxt_policy_group.w01_vc.path,]
    logged             = false
  }

  rule {
    display_name       = "NSX to vCenter"
    source_groups      = [nsxt_policy_group.w01_nsx.path]
    destination_groups = [nsxt_policy_group.w01_vc.path]
    services           = [data.nsxt_policy_service.http.path,data.nsxt_policy_service.tcp_9087.path]
    action             = "ALLOW"
    scope              = [nsxt_policy_group.w01_vc.path,nsxt_policy_group.w01_nsx.path]
    logged             = false
  }

#  rule {
#    display_name       = "NSX to SDDC Manager"
#    source_groups      = [nsxt_policy_group.w01_nsx.path]
#    destination_groups = [nsxt_policy_group.sddc_mgr.path]
#    services           = [data.nsxt_policy_service.ssh.path]
#    action             = "ALLOW"
#    scope              = [nsxt_policy_group.sddc_mgr.path,nsxt_policy_group.w01_nsx.path]
#    logged             = false
#  }

  rule {
    display_name       = "NSX Messaging"
    source_groups      = [nsxt_policy_group.w01_nsx.path,nsxt_policy_group.w01_hosts.path,nsxt_policy_group.w01_edges.path]
    destination_groups = [nsxt_policy_group.w01_nsx.path,nsxt_policy_group.w01_hosts.path,nsxt_policy_group.w01_edges.path]
    services           = [nsxt_policy_service.tcp_1234_1235.path,nsxt_policy_service.tcp_5671.path]
    action             = "ALLOW"
    scope              = [nsxt_policy_group.w01_nsx.path]
    logged             = false
  }

  rule {
    display_name       = "NSX Manager Cluster"
    source_groups      = [nsxt_policy_group.w01_nsx.path]
    destination_groups = [nsxt_policy_group.w01_nsx.path]
    services           = [nsxt_policy_service.tcp_9000.path,nsxt_policy_service.tcp_9040.path,data.nsxt_policy_service.icmp_all.path]
    action             = "ALLOW"
    scope              = [nsxt_policy_group.w01_nsx.path]
    logged             = false
  }

  rule {
    display_name       = "W01_WLD Default Drop"
    scope              = [nsxt_policy_group.w01_wld.path]
    action             = "DROP"
    logged             = true
    log_label          = "w01_wld"
  }
}
