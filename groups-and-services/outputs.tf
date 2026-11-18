output "group_paths" {
  description = "Map of all NSX group names defined in this module to their policy path, for consumption by every policy-bearing module (environment, infrastructure, application/*)"
  value = merge({
    backup_svc = nsxt_policy_group.backup_svc.path
    bastion    = nsxt_policy_group.bastion.path
    smtp_svc   = nsxt_policy_group.smtp_svc.path
    tools      = nsxt_policy_group.tools.path

    vcf_a            = nsxt_policy_group.vcf_a.path
    vcf_a_lb         = nsxt_policy_group.vcf_a_lb.path
    vcf_fleet        = nsxt_policy_group.vcf_fleet.path
    vcf_fm           = nsxt_policy_group.vcf_fm.path
    vcf_lhub         = nsxt_policy_group.vcf_lhub.path
    vcf_lic          = nsxt_policy_group.vcf_lic.path
    vcf_ops          = nsxt_policy_group.vcf_ops.path
    vcf_ops_net      = nsxt_policy_group.vcf_ops_net.path
    vcf01_msvc       = nsxt_policy_group.vcf01_msvc.path
    vcf01_m01        = nsxt_policy_group.vcf01_m01.path
    vcf01_w01        = nsxt_policy_group.vcf01_w01.path
    vcf01_ops_cp     = nsxt_policy_group.vcf01_ops_cp.path
    vcf01_ops_net_cn = nsxt_policy_group.vcf01_ops_net_cn.path
    vcf01_sddc       = nsxt_policy_group.vcf01_sddc.path

    m01_vc      = nsxt_policy_group.m01_vc.path
    m01_nsx     = nsxt_policy_group.m01_nsx.path
    m01_avi     = nsxt_policy_group.m01_avi.path
    m01_avi_se  = nsxt_policy_group.m01_avi_se.path
    m01_edges   = nsxt_policy_group.m01_edges.path
    m01_hosts   = nsxt_policy_group.m01_hosts.path
    vcf01_sspi  = nsxt_policy_group.vcf01_sspi.path
    m01_ssp     = nsxt_policy_group.m01_ssp.path
    m01_ssp_svc = nsxt_policy_group.m01_ssp_svc.path

    w01_vc     = nsxt_policy_group.w01_vc.path
    w01_nsx    = nsxt_policy_group.w01_nsx.path
    w01_avi    = nsxt_policy_group.w01_avi.path
    w01_avi_se = nsxt_policy_group.w01_avi_se.path
    w01_edges  = nsxt_policy_group.w01_edges.path
    w01_hosts  = nsxt_policy_group.w01_hosts.path
    w01_sup01  = nsxt_policy_group.w01_sup01.path
    }, var.external_services.syslog_server != null ? {
    # Only present when an external syslog collector is configured (external_services.syslog_server).
    syslog_svc = nsxt_policy_group.syslog_svc[0].path
    } : {}, local.w01_ssp_enabled ? {
    # Only present once SSP is deployed on w01 (var.w01.ssp is set).
    w01_sspi    = nsxt_policy_group.w01_sspi[0].path
    w01_ssp     = nsxt_policy_group.w01_ssp[0].path
    w01_ssp_svc = nsxt_policy_group.w01_ssp_svc[0].path
  } : {})
}

output "service_paths" {
  description = "Map of NSX service names to their policy path (custom services defined in this module plus the built-in services from builtin-services.tf), for consumption by every policy-bearing module (environment, infrastructure, application/*)"
  value = merge(local.builtin_service_paths, {
    tcp_1234_1235   = nsxt_policy_service.tcp_1234_1235.path
    tcp_1443        = nsxt_policy_service.tcp_1443.path
    tcp_1514        = nsxt_policy_service.tcp_1514.path
    tcp_1991        = nsxt_policy_service.tcp_1991.path
    tcp_2049        = nsxt_policy_service.tcp_2049.path
    tcp_3260        = nsxt_policy_service.tcp_3260.path
    tcp_30000_30005 = nsxt_policy_service.tcp_30000_30005.path
    tcp_4505_4506   = nsxt_policy_service.tcp_4505_4506.path
    tcp_5480        = nsxt_policy_service.tcp_5480.path
    tcp_5671        = nsxt_policy_service.tcp_5671.path
    tcp_6443        = nsxt_policy_service.tcp_6443.path
    tcp_6500        = nsxt_policy_service.tcp_6500.path
    tcp_6501_6502   = nsxt_policy_service.tcp_6501_6502.path
    tcp_7475_7476   = nsxt_policy_service.tcp_7475_7476.path
    tcp_8443        = nsxt_policy_service.tcp_8443.path
    tcp_9092        = nsxt_policy_service.tcp_9092.path
    tcp_9543        = nsxt_policy_service.tcp_9543.path
    udp_2055        = nsxt_policy_service.udp_2055.path

  })
}

output "context_profile_paths" {
  description = "Map of NSX context profile names to their policy path (custom profiles defined in this module plus the built-in profiles from builtin-services.tf), for consumption by every policy-bearing module (environment, infrastructure, application/*)"
  value = merge(local.builtin_context_profile_paths, {
    internet_fqdns = nsxt_policy_context_profile.internet_fqdns.path
  })
}
