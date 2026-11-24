# Terraform and provider version constraints are declared in versions.tf.

provider "nsxt" {
  host                  = var.nsx_manager
  username              = var.nsx_username
  password              = var.nsx_password
  allow_unverified_ssl  = var.nsx_allow_unverified_ssl
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
}

module "groups_and_services" {
  source = "./groups-and-services"

  external_services = var.external_services
  fleet             = var.fleet
  m01               = var.m01
  w01               = var.w01
}

module "environment" {
  source = "./environment"

  group_paths           = module.groups_and_services.group_paths
  service_paths         = module.groups_and_services.service_paths
  context_profile_paths = module.groups_and_services.context_profile_paths
}

module "infrastructure" {
  source = "./infrastructure"

  group_paths           = module.groups_and_services.group_paths
  service_paths         = module.groups_and_services.service_paths
  context_profile_paths = module.groups_and_services.context_profile_paths
}

module "application_fm" {
  source = "./application/fm"

  group_paths   = module.groups_and_services.group_paths
  service_paths = module.groups_and_services.service_paths
}

module "application_m01" {
  source = "./application/m01"

  group_paths   = module.groups_and_services.group_paths
  service_paths = module.groups_and_services.service_paths
}

module "application_w01" {
  source = "./application/w01"

  ssp_enabled = var.w01.ssp != null

  group_paths   = module.groups_and_services.group_paths
  service_paths = module.groups_and_services.service_paths
}
