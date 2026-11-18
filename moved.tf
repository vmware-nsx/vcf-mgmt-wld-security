# State moves for the DNS, NTP, DHCP and AD groups, which now live in the groups-and-services module.
# A deployment whose state was created before the move keeps these four groups: run `terraform apply`
# once to record the move, then delete this file. A new deployment does not need it.

moved {
  from = module.infrastructure.nsxt_policy_group.dns_svc
  to   = module.groups_and_services.nsxt_policy_group.dns_svc
}

moved {
  from = module.infrastructure.nsxt_policy_group.ntp_svc
  to   = module.groups_and_services.nsxt_policy_group.ntp_svc
}

moved {
  from = module.infrastructure.nsxt_policy_group.dhcp_svc
  to   = module.groups_and_services.nsxt_policy_group.dhcp_svc
}

moved {
  from = module.infrastructure.nsxt_policy_group.ad_svc
  to   = module.groups_and_services.nsxt_policy_group.ad_svc
}
