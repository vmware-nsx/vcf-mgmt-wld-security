# Input validation lives on the root module variables (variables.tf).

variable "external_services" {
  type = object({
    dns_server    = string
    ntp_server    = string
    dhcp_server   = string
    ad_server     = string
    smtp_server   = string
    bastion_host  = string
    tools_server  = string
    backup_server = string
    syslog_server = optional(string)
  })
  description = <<-EOT
    IP addresses of the services outside the VCF fleet that the fleet is allowed to reach or be reached from:
    DNS, NTP, DHCP, Active Directory, SMTP, the bastion/jump host, the automation/tools server and the backup server.
    Optional: syslog_server, an external syslog collector; the SYSLOG_SVC group is created only when it is set.
  EOT
}

variable "fleet" {
  type = object({
    vcfops01    = string
    vcfmsvc     = string
    vcfa        = string
    vcfa_vip    = string
    vcf_lic     = string
    vcf_lhub    = string
    vcf_lhub_ip = string
    sddc        = string
    vcfops_cp   = string
    sspi        = string
    ops_net = optional(object({
      platform  = string
      collector = string
    }))
  })
  description = <<-EOT
    VCF Fleet Management components.
      vcfops01     VCF Operations VM name
      vcfmsvc      VCF Management Services VM name prefix
      vcfa         VCF Automation VM name prefix
      vcfa_vip     VCF Automation load balancer virtual IP
      vcf_lic      VCF License Server VM name
      vcf_lhub     vDefend License Hub VM name
      vcf_lhub_ip  vDefend License Hub additional IP address (for example a virtual IP)
      sddc         SDDC Manager VM name
      vcfops_cp    VCF Operations Cloud Proxy VM name
      sspi         Security Services Platform Installer (SSPI) VM name
      ops_net      Optional. VCF Operations for Networks platform and collector VM names; leave null if not deployed
  EOT


}

variable "m01" {
  type = object({
    vcenter         = string
    nsx_managers    = list(string)
    avi_controllers = list(string)
    edges           = string
    hosts           = string
    avi_se_mgmt     = string
    ssp_svc         = string
  })
  description = <<-EOT
    Management domain (m01) components.
      vcenter          vCenter Server VM name
      nsx_managers     NSX Manager node VM names (1 to 3); each is tagged and matched by name
      avi_controllers  NSX ALB (Avi) Controller node VM names (1 to 3); use [] if Avi is not deployed
      edges            NSX Edge node IPs: an address, a range (a.b.c.d-e.f.g.h) or a CIDR block
      hosts            ESXi host IPs: an address, a range or a CIDR block
      avi_se_mgmt      Avi Service Engine management network: an address, a range or a CIDR block
      ssp_svc          Security Services Platform (SSP) services IP range: an address, a range or a CIDR block
  EOT



}

variable "w01" {
  type = object({
    vcenter      = string
    nsx_managers = list(string)
    edges        = string
    hosts        = string
    sup01        = string
    ssp = optional(object({
      sspi_vm = string
      ssp_svc = string
    }))
  })
  description = <<-EOT
    Workload domain 01 (w01) components.
      vcenter          vCenter Server VM name
      nsx_managers     NSX Manager node VM names (1 to 3); each is tagged and matched by name
      edges            NSX Edge node IPs: an address, a range (a.b.c.d-e.f.g.h) or a CIDR block
      hosts            ESXi host IPs: an address, a range or a CIDR block
      sup01            Supervisor node IP range: an address, a range or a CIDR block
      ssp              Optional. Security Services Platform for this domain: sspi_vm (SSPI VM name) and
                       ssp_svc (SSP services IP range). Leave null until SSP is deployed; setting it creates
                       the w01 SSP groups and the "Workload Domain 01 SSP Policy"
  EOT




}
