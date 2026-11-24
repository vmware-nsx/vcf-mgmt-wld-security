# NSX Manager connection
#
# Provide these through the environment, not through a tfvars file (values in a tfvars file override
# TF_VAR_* variables):
#   export TF_VAR_nsx_manager=... TF_VAR_nsx_username=... TF_VAR_nsx_password=...

variable "nsx_manager" {
  type        = string
  description = "NSX Manager cluster VIP hostname or IP address"

  validation {
    condition     = length(trimspace(var.nsx_manager)) > 0 && !can(regex("[<>]", var.nsx_manager))
    error_message = "nsx_manager must be set to the NSX Manager host name or IP address (it still contains a <placeholder>, or is empty). Export TF_VAR_nsx_manager instead of setting it in a tfvars file."
  }
}

variable "nsx_username" {
  type        = string
  description = "NSX Manager Enterprise Administrator username"

  validation {
    condition     = length(trimspace(var.nsx_username)) > 0 && !can(regex("[<>]", var.nsx_username))
    error_message = "nsx_username must be set (it still contains a <placeholder>, or is empty). Export TF_VAR_nsx_username instead of setting it in a tfvars file."
  }
}

variable "nsx_password" {
  type        = string
  sensitive   = true
  description = "NSX Manager Enterprise Administrator password"

  validation {
    condition     = length(var.nsx_password) > 0 && !can(regex("^<.*>$", var.nsx_password))
    error_message = "nsx_password must be set (it is empty, or still a <placeholder>). Export TF_VAR_nsx_password instead of setting it in a tfvars file."
  }
}

variable "nsx_allow_unverified_ssl" {
  type        = bool
  default     = false
  description = "Skip TLS certificate verification for the NSX Manager. Leave false for production; set true only for labs that use self-signed certificates"
}

# External services

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
    Optional: syslog_server, an external syslog collector. Setting it creates the SYSLOG_SVC group and adds a Syslog
    rule to the "VCF Fleet Infrastructure" policy (and syslog to its Lock Down services); leave it null if the fleet logs only to VCF Management Services.
  EOT

  validation {
    condition     = alltrue([for ip in values(var.external_services) : ip == null || can(regex("^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}$", ip))])
    error_message = "Every value in external_services (dns_server, ntp_server, dhcp_server, ad_server, smtp_server, bastion_host, tools_server, backup_server and, when set, syslog_server) must be an IPv4 address."
  }
}

# VCF Fleet

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

  validation {
    condition     = alltrue([for n in [var.fleet.vcfops01, var.fleet.vcfmsvc, var.fleet.vcfa, var.fleet.vcf_lic, var.fleet.vcf_lhub, var.fleet.sddc, var.fleet.vcfops_cp, var.fleet.sspi] : length(trimspace(n)) > 0])
    error_message = "The fleet VM names (vcfops01, vcfmsvc, vcfa, vcf_lic, vcf_lhub, sddc, vcfops_cp, sspi) must not be empty."
  }

  validation {
    condition     = alltrue([for ip in [var.fleet.vcfa_vip, var.fleet.vcf_lhub_ip] : can(regex("^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}$", ip))])
    error_message = "fleet.vcfa_vip and fleet.vcf_lhub_ip must be IPv4 addresses."
  }

  validation {
    condition     = var.fleet.ops_net == null ? true : (length(trimspace(var.fleet.ops_net.platform)) > 0 && length(trimspace(var.fleet.ops_net.collector)) > 0)
    error_message = "fleet.ops_net.platform and fleet.ops_net.collector must not be empty (set fleet.ops_net to null if Operations for Networks is not deployed)."
  }
}

# VCF01 Management Domain (m01)

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

  validation {
    condition     = length(trimspace(var.m01.vcenter)) > 0
    error_message = "m01.vcenter must not be empty."
  }

  validation {
    condition     = length(var.m01.nsx_managers) >= 1 && alltrue([for n in var.m01.nsx_managers : length(trimspace(n)) > 0])
    error_message = "m01.nsx_managers must list at least one NSX Manager VM name, and no empty names."
  }

  validation {
    condition     = alltrue([for n in var.m01.avi_controllers : length(trimspace(n)) > 0])
    error_message = "m01.avi_controllers must not contain empty VM names (use [] if Avi is not deployed)."
  }

  validation {
    condition     = alltrue([for r in [var.m01.edges, var.m01.hosts, var.m01.avi_se_mgmt, var.m01.ssp_svc] : can(regex("^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}(-(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}|/(3[0-2]|[12]?[0-9]))?$", r))])
    error_message = "m01.edges, m01.hosts, m01.avi_se_mgmt and m01.ssp_svc must each be an IPv4 address, an address range (a.b.c.d-e.f.g.h) or a CIDR block (a.b.c.d/nn)."
  }
}

# VCF01 Workload Domain 01 (w01)

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

  validation {
    condition     = length(trimspace(var.w01.vcenter)) > 0
    error_message = "w01.vcenter must not be empty."
  }

  validation {
    condition     = length(var.w01.nsx_managers) >= 1 && alltrue([for n in var.w01.nsx_managers : length(trimspace(n)) > 0])
    error_message = "w01.nsx_managers must list at least one NSX Manager VM name, and no empty names."
  }

  validation {
    condition     = alltrue([for r in [var.w01.edges, var.w01.hosts, var.w01.sup01] : can(regex("^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}(-(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}|/(3[0-2]|[12]?[0-9]))?$", r))])
    error_message = "w01.edges, w01.hosts and w01.sup01 must each be an IPv4 address, an address range (a.b.c.d-e.f.g.h) or a CIDR block (a.b.c.d/nn)."
  }

  validation {
    condition     = var.w01.ssp == null ? true : (length(trimspace(var.w01.ssp.sspi_vm)) > 0 && can(regex("^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}(-(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}|/(3[0-2]|[12]?[0-9]))?$", var.w01.ssp.ssp_svc)))
    error_message = "w01.ssp.sspi_vm must not be empty and w01.ssp.ssp_svc must be an IPv4 address, an address range (a.b.c.d-e.f.g.h) or a CIDR block (a.b.c.d/nn)."
  }
}
