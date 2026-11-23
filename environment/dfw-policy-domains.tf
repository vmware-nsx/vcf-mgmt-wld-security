# Environment policies for the VCF01 domains (management domain m01 and workload domain 01 w01).
#
# The domains get the same set of rules, so the policies are generated from one rule table with
# for_each. Add a workload domain by adding an entry to local.domains (and its groups in the
# groups-and-services module). Differences between domains are data in local.domains:
#   backup_sources  groups that back up their configuration to the SDDC Manager over SSH
#   extra_rules     rules that exist for one domain only (the Supervisor rules on w01)
#
# Each rule is an object using the nsxt_policy_security_policy rule argument names; omitted
# arguments take the provider defaults (any source/destination/service, either direction).

locals {
  domains = {
    m01 = {
      label           = "Management Domain"
      display_name    = "VCF01 Management Domain"
      description     = "VCF01 Management Domain Environment"
      sequence_number = 3
      group           = var.group_paths["vcf01_m01"]
      vcenter         = var.group_paths["m01_vc"]
      backup_sources  = [var.group_paths["m01_nsx"], var.group_paths["m01_avi"]]
      log_label       = "vcf_m01"
      extra_rules     = []
    }
    w01 = {
      label           = "Workload Domain"
      display_name    = "VCF01 Workload Domain"
      description     = "VCF01 Workload Domain 01 Environment"
      sequence_number = 4
      group           = var.group_paths["vcf01_w01"]
      vcenter         = var.group_paths["w01_vc"]
      backup_sources  = [var.group_paths["w01_nsx"]]
      log_label       = "vcf_w01"
      extra_rules = [
        {
          display_name       = "Supervisor to Workload Domain"
          source_groups      = [var.group_paths["w01_sup01"]]
          destination_groups = [var.group_paths["vcf01_w01"]]
          services           = [var.service_paths["https"]]
          action             = "ALLOW"
          direction          = "IN"
        },
        {
          display_name       = "Workload Domain to Supervisor"
          source_groups      = [var.group_paths["vcf01_w01"]]
          destination_groups = [var.group_paths["w01_sup01"]]
          services           = [var.service_paths["tcp_6443"]]
          action             = "ALLOW"
          direction          = "OUT"
        },
      ]
    }
  }

  domain_rules = {
    for key, d in local.domains : key => concat(
      [
        {
          display_name       = "${d.label} (Intra)"
          source_groups      = [d.group]
          destination_groups = [d.group]
          action             = "JUMP_TO_APPLICATION"
        },
        {
          display_name       = "VCF Fleet Management to ${d.label}"
          source_groups      = [var.group_paths["vcf_fm"]]
          destination_groups = [d.group]
          services           = [var.service_paths["https"]]
          action             = "ALLOW"
          direction          = "IN"
        },
        {
          display_name       = "SDDC Manager to ${d.label}"
          source_groups      = [var.group_paths["vcf01_sddc"]]
          destination_groups = [d.group]
          services           = [var.service_paths["ssh"], var.service_paths["tcp_5480"], var.service_paths["icmp_echo"]]
          action             = "ALLOW"
          direction          = "IN"
        },
        {
          # Disabled: VCF01 Backup Traffic in the VCF Fleet policy already allows this flow.
          display_name       = "Components Backup on the SDDC Manager"
          source_groups      = d.backup_sources
          destination_groups = [var.group_paths["vcf01_sddc"]]
          services           = [var.service_paths["ssh"]]
          action             = "ALLOW"
          direction          = "OUT"
          disabled           = true
        },
        {
          display_name       = "VCF OPS CP to ${d.label}"
          source_groups      = [var.group_paths["vcf01_ops_cp"]]
          destination_groups = [d.group]
          services           = [var.service_paths["icmp_echo"]]
          action             = "ALLOW"
          direction          = "IN"
        },
        {
          display_name       = "${d.label} to VCF Management Services"
          source_groups      = [d.group]
          destination_groups = [var.group_paths["vcf01_msvc"]]
          services           = [var.service_paths["https"], var.service_paths["tcp_4505_4506"]]
          action             = "ALLOW"
          direction          = "OUT"
        },
        {
          display_name       = "${d.label} to VCF Ops for Net"
          source_groups      = [d.group]
          destination_groups = [var.group_paths["vcf01_ops_net_cn"]]
          services           = [var.service_paths["https"], var.service_paths["tcp_1991"], var.service_paths["udp_2055"]]
          action             = "ALLOW"
          direction          = "OUT"
        },
        {
          display_name       = "${d.label} vCenter Server to VCF License Server"
          source_groups      = [d.vcenter]
          destination_groups = [var.group_paths["vcf_lic"]]
          services           = [var.service_paths["https"]]
          action             = "ALLOW"
          direction          = "OUT"
        },
        {
          display_name       = "vDefend License Hub to Endpoints"
          source_groups      = [var.group_paths["vcf_lhub"]]
          destination_groups = [d.group]
          services           = [var.service_paths["tcp_2049"], var.service_paths["tcp_3260"]]
          action             = "ALLOW"
          direction          = "IN"
        },
        {
          display_name       = "Endpoints to vDefend License Hub"
          source_groups      = [d.group]
          destination_groups = [var.group_paths["vcf_lhub"]]
          services           = [var.service_paths["https"], var.service_paths["tcp_9092"]]
          action             = "ALLOW"
          direction          = "OUT"
        },
        {
          display_name       = "SSPI to ${d.label}"
          source_groups      = [var.group_paths["vcf01_sspi"]]
          destination_groups = [d.group]
          services           = [var.service_paths["tcp_6443"], var.service_paths["ssh"]]
          action             = "ALLOW"
          direction          = "IN"
        },
        {
          display_name       = "${d.label} to SSPI"
          source_groups      = [d.group]
          destination_groups = [var.group_paths["vcf01_sspi"]]
          services           = [var.service_paths["https"]]
          action             = "ALLOW"
          direction          = "OUT"
        },
      ],
      d.extra_rules,
      [
        {
          display_name = "${d.label} (Lock Down)"
          action       = "DROP"
          logged       = true
          log_label    = d.log_label
        },
      ]
    )
  }
}

resource "nsxt_policy_security_policy" "domain" {
  for_each = local.domains

  display_name    = each.value.display_name
  description     = each.value.description
  category        = "Environment"
  locked          = false
  stateful        = true
  tcp_strict      = true
  scope           = [each.value.group]
  sequence_number = each.value.sequence_number

  dynamic "rule" {
    for_each = local.domain_rules[each.key]

    content {
      display_name       = rule.value.display_name
      source_groups      = try(rule.value.source_groups, null)
      destination_groups = try(rule.value.destination_groups, null)
      services           = try(rule.value.services, null)
      action             = rule.value.action
      direction          = try(rule.value.direction, null)
      disabled           = try(rule.value.disabled, false)
      ip_version         = "IPV4"
      logged             = try(rule.value.logged, false)
      log_label          = try(rule.value.log_label, null)
    }
  }
}
