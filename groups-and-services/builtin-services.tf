# Built-in (system-owned) NSX services and context profiles, referenced by their fixed IDs.
#
# These objects ship with NSX and their IDs are stable, so they are referenced by policy path
# instead of being looked up by display name with `data` sources. That removes ~25 API lookups
# and the "found more than one object with this name" failure mode of name lookups.
# Every policy module consumes them through `service_paths` / `context_profile_paths`.
locals {
  builtin_service_paths = {
    https       = "/infra/services/HTTPS"
    http        = "/infra/services/HTTP"
    ssh         = "/infra/services/SSH"
    rdp         = "/infra/services/RDP"
    ftp         = "/infra/services/FTP"
    smtp        = "/infra/services/SMTP"
    smtp_tls    = "/infra/services/SMTP_TLS"
    icmp_all    = "/infra/services/ICMP-ALL"
    icmp_echo   = "/infra/services/ICMP_Echo_Request"
    dns_tcp     = "/infra/services/DNS"
    dns_udp     = "/infra/services/DNS-UDP"
    ntp         = "/infra/services/NTP"
    dhcp_server = "/infra/services/DHCP-Server"
    activdir    = "/infra/services/Microsoft_Active_Directory_V1"
    syslog_tcp  = "/infra/services/Syslog_(TCP)"
    syslog_udp  = "/infra/services/Syslog_(UDP)"

    # vSphere Update Manager / ESXi
    update_manager = "/infra/services/Update_Manager"
    udp_902        = "/infra/services/VMware-ESXi5.x-UDP"
    tcp_9084       = "/infra/services/VMware-UpdateMgr-VUM"
    tcp_9087       = "/infra/services/Vmware-UpdateMgr-update"
  }

  builtin_context_profile_paths = {
    ssl = "/infra/context-profiles/SSL"
    dns = "/infra/context-profiles/DNS"
  }
}
