# Environment services

variable "smtp_server" {
  type        = string
  description = "SMTP server IP address"
}

variable "bastion_host" {
  type        = string
  description = "Bastion/jump host IP address"
}

variable "tools_server" {
  type        = string
  description = "Automation/tools server IP address"
}

variable "backup_server" {
  type        = string
  description = "Backup server IP address"
}

variable "siem_server" {
  type        = string
  description = "SIEM server IP address"
}

# VCF Fleet Management VM name prefixes / identifiers

variable "vcfops01" {
  type        = string
  description = "VCF Operations (Aria Operations) VM name"
}

variable "vcfmsvc" {
  type        = string
  description = "VCF Management Services VM name prefix"
}

variable "vcfops_logs" {
  type        = string
  description = "VCF Operations for Logs (Aria Operations for Logs) VM name"
}

variable "vcfops_net" {
  type        = string
  description = "VCF Operations for Networks (Aria Operations for Networks) platform VM name"
}

variable "vcfa" {
  type        = string
  description = "VCF Automation (Aria Automation) VM name prefix"
}

variable "vcf_lic" {
  type        = string
  description = "VCF License Server VM name"
}

variable "vcf_lhub" {
  type        = string
  description = "vDefend License Hub VM name"
}

variable "sddc" {
  type        = string
  description = "SDDC Manager VM name"
}

variable "vcfops_cp" {
  type        = string
  description = "VCF Operations Cloud Proxy VM name"
}

variable "vcfops_net_cn" {
  type        = string
  description = "VCF Operations for Networks collector node VM name"
}

# VCF01 Management Domain (m01) components

variable "m01_vcenter" {
  type        = string
  description = "Management domain vCenter Server VM name"
}

variable "m01_nsx_manager_a" {
  type        = string
  description = "Management domain NSX Manager node A VM name"
}

variable "m01_nsx_manager_b" {
  type        = string
  description = "Management domain NSX Manager node B VM name"
}

variable "m01_nsx_manager_c" {
  type        = string
  description = "Management domain NSX Manager node C VM name"
}

variable "m01_avi_controller_a" {
  type        = string
  description = "Management domain NSX ALB (Avi) Controller node A VM name"
}

variable "m01_avi_controller_b" {
  type        = string
  description = "Management domain NSX ALB (Avi) Controller node B VM name"
}

variable "m01_avi_controller_c" {
  type        = string
  description = "Management domain NSX ALB (Avi) Controller node C VM name"
}

variable "m01_edges" {
  type        = string
  description = "Management domain NSX Edge node IP range (e.g. 172.16.10.61-172.16.10.64)"
}

variable "m01_hosts" {
  type        = string
  description = "Management domain ESXi host IP range (e.g. 172.16.11.11-172.16.11.14)"
}

variable "m01_sspi_vm" {
  type        = string
  description = "Management domain vSphere Authentication Proxy (SSPI) VM name"
}

variable "m01_sspm" {
  type        = string
  description = "Management domain Supervisor Primary Master IP range"
}

# VCF01 Workload Domain 01 (w01) components

variable "w01_vcenter" {
  type        = string
  description = "Workload domain 01 vCenter Server VM name"
}

variable "w01_nsx_manager_a" {
  type        = string
  description = "Workload domain 01 NSX Manager node A VM name"
}

variable "w01_nsx_manager_b" {
  type        = string
  description = "Workload domain 01 NSX Manager node B VM name"
}

variable "w01_nsx_manager_c" {
  type        = string
  description = "Workload domain 01 NSX Manager node C VM name"
}

variable "w01_avi_controller_a" {
  type        = string
  description = "Workload domain 01 NSX ALB (Avi) Controller node A VM name"
}

variable "w01_avi_controller_b" {
  type        = string
  description = "Workload domain 01 NSX ALB (Avi) Controller node B VM name"
}

variable "w01_avi_controller_c" {
  type        = string
  description = "Workload domain 01 NSX ALB (Avi) Controller node C VM name"
}

variable "w01_edges" {
  type        = string
  description = "Workload domain 01 NSX Edge node IP range (e.g. 172.16.10.71-172.16.10.74)"
}

variable "w01_hosts" {
  type        = string
  description = "Workload domain 01 ESXi host IP range (e.g. 172.16.11.15-172.16.11.17)"
}

variable "w01_sspi_vm" {
  type        = string
  description = "Workload domain 01 vSphere Authentication Proxy (SSPI) VM name"
}

variable "w01_sspm" {
  type        = string
  description = "Workload domain 01 Supervisor Primary Master IP range"
}

variable "w01_sup01" {
  type        = string
  description = "Workload domain 01 Supervisor node IP range (e.g. 172.16.10.101-172.16.10.110)"
}

# vSphere

variable "vm_management_dvpg" {
  type        = string
  description = "VM Management distributed port group name (format: vds-name.pg-name)"
}
