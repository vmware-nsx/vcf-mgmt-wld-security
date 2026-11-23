# Securing the VMware Cloud Foundation management domain with VMware vDefend

Terraform configuration to automate the deployment of vDefend Distributed Firewall (DFW) policies that secure VMware Cloud Foundation (VCF) management components, including VCF Fleet, VCF Fleet management service, SDDC Manager, vCenter Servers, NSX Managers, vDefend Security Services Platform, Avi Load Balancer, etc.

## Disclaimer

This configuration is provided as a reference example of how to quickly secure VCF management components. You are solely responsible for reviewing, adapting, and validating it for your own environment before applying it in production.

## Applicable Versions

| Component | Version |
|-----------|---------|
| VMware Cloud Foundation | 9.1.x |
| Terraform CLI | 1.6.0 or later |
| NSX Terraform Provider (`vmware/nsxt`) | `~> 3.12` (tested with 3.12.1) |

The provider and Terraform versions are constrained in `versions.tf`, and the provider build is
pinned by the committed `.terraform.lock.hcl` (checksums for Linux, macOS and Windows). Use
`terraform init -upgrade` only when you intend to move to a newer provider release, and commit the
updated lock file afterwards.

## Prerequisites

- VCF 9.1.x deployment with at least one management domain and one workload domain
- NSX Manager accessible from the Terraform host
- **NSX on DVPGs** enabled on all vSphere clusters whose VMs should be protected
- Terraform CLI installed on the host running these configurations
- NSX Enterprise Administrator credentials

## Repository Structure

The configuration is split into a root module, a shared `groups-and-services` module that
owns every NSX group and service, and per-category/per-domain policy child
modules, so that each policy module can be planned/applied independently with
`-target=module.<name>`:

```
.
├── main.tf                    # Provider configuration and module wiring
├── versions.tf                # Terraform and provider version constraints
├── variables.tf               # Input variable declarations (all modules' inputs)
├── terraform.tfvars.example   # Example variable values (copy to terraform.tfvars, which is git-ignored)
├── .terraform.lock.hcl        # Pinned provider build (committed on purpose)
├── groups-and-services/       # All NSX groups and custom services
├── infrastructure/            # DFW "Infrastructure" category module
├── environment/               # DFW "Environment" category module
└── application/               # DFW "Application" category modules
    ├── fm/                    #   VCF Fleet Management application policies
    ├── m01/                   #   Management domain (m01) application policies
    └── w01/                   #   Workload domain 01 (w01) application policies
```

| Module | File | Description |
|--------|------|-------------|
| root | `main.tf` | Terraform provider configuration and `module` blocks for `groups_and_services`, `infrastructure`, `environment`, and the three `application` modules |
| root | `variables.tf` | Input variable declarations: the NSX connection plus the grouped `external_services`, `fleet`, `m01` and `w01` objects, with input validation |
| root | `versions.tf` | Terraform and provider version constraints |
| root | `terraform.tfvars.example` | Example variable values (copy to the git-ignored `terraform.tfvars` and edit) |
| `groups-and-services` | `groups-vcf_ext.tf` | NSX groups for external services (DNS, NTP, DHCP, AD, bastion, tools, backup, SMTP and, when configured, syslog) |
| `groups-and-services` | `groups-vcf_fm.tf` | NSX groups for VCF Fleet Management components |
| `groups-and-services` | `groups-vcf01_m01.tf` | NSX groups for management domain (m01) components |
| `groups-and-services` | `groups-vcf01_w01.tf` | NSX groups for workload domain 01 (w01) components |
| `groups-and-services` | `services.tf` | Custom NSX services and the custom context profile shared across policy modules |
| `groups-and-services` | `builtin-services.tf` | Fixed paths of the built-in NSX services and context profiles (HTTPS, SSH, DNS, ...), exposed through `service_paths` / `context_profile_paths` |
| `groups-and-services` | `variables.tf` / `outputs.tf` / `versions.tf` | Module inputs, the `group_paths`/`service_paths`/`context_profile_paths` maps consumed by every other module, and provider requirements |
| `infrastructure` | `dfw-policy-infrastructure.tf` | DFW Infrastructure category policy |
| `infrastructure` | `variables.tf` / `versions.tf` | Module inputs (`group_paths`, `service_paths`, `context_profile_paths`) and provider requirements |
| `environment` | `dfw-policy-environment.tf` | The VCF Fleet External and VCF Fleet Management Environment policies |
| `environment` | `dfw-policy-environment-domains.tf` | The VCF01 Management Domain and VCF01 Workload Domain Environment policies, generated with `for_each` from one rule table (`local.domains`) |
| `environment` | `variables.tf` / `versions.tf` | Module inputs (`group_paths`, `service_paths`, `context_profile_paths`) and provider requirements |
| `application/fm` | `dfw-policy-application-fm.tf` | Application policies for VCF Operations, VCF Automation, VCF Management Services (`VCF01_MSVC`), VCF License (`VCF_LIC`), vDefend License Hub (`VCF_LHUB`), VCF SDDC Manager (`VCF01_SDDC`), and VCF Operations for Networks |
| `application/m01` | `dfw-policy-application-m01.tf` | Application policies for the management domain's vCenter, Avi, and SSP components |
| `application/w01` | `dfw-policy-application-w01.tf` | Application policies for workload domain 01's vCenter and NSX components, plus the SSP policy when `w01.ssp` is set |
| `application/*` | `variables.tf` / `versions.tf` | Module inputs (`group_paths`, `service_paths`, plus `ssp_enabled` for `application/w01`) and provider requirements |

Every NSX group and service is defined exactly once, in `groups-and-services`, and exposed via its `group_paths` /
`service_paths` / `context_profile_paths` outputs. `environment`, `infrastructure`,
and all three `application` modules consume those maps identically
(`var.group_paths["x"]`, `var.service_paths["x"]`) — only `groups-and-services` itself
references the underlying resources directly.

Built-in NSX services (HTTPS, SSH, DNS, ...) and context profiles are referenced by their fixed
policy paths in `groups-and-services/builtin-services.tf` instead of being looked up by display
name with `data` sources, so no policy module needs API lookups to build a rule.

**Dependencies and apply order.** `environment`, `infrastructure`, and all three
`application` modules depend only on `groups-and-services` — not on each other — so they
can be applied in any order relative to one another; `terraform apply -target=module.<name>`
for any of them automatically creates the `groups-and-services` resources it needs first.

**Optional components.** Some parts of the configuration are switched on by setting an optional
attribute in your tfvars; leave it `null` (or `[]` for lists) while the component is not deployed:

| Attribute | Switches on |
|-----------|-------------|
| `fleet.ops_net` (`platform`, `collector`) | VM tags for VCF Operations for Networks |
| `external_services.syslog_server` | The `SYSLOG_SVC` group, the Syslog rule in the "VCF Fleet Infrastructure" policy and the syslog services in its Lock Down rule |
| `w01.ssp` (`sspi_vm`, `ssp_svc`) | The `w01_sspi` / `w01_ssp` / `w01_ssp_svc` groups, their nesting in `VCF01_W01`, and the "Workload Domain 01 SSP Policy" |
| `m01.avi_controllers` | Tagging and name matching of the management domain Avi Controller VMs; `[]` leaves `M01_AVI` empty |

The management domain SSP (`fleet.sspi`, `m01_ssp`, `m01.ssp_svc`) is always created.

**Adding VM nodes.** `nsx_managers` (both domains) and `m01.avi_controllers` list one VM name per node (1 to 3).
Every listed VM is tagged and matched by name in the domain's NSX / Avi group.

## Naming conventions

- **Group and service resource names** are lower-case with underscores and mirror the NSX object:
  `nsxt_policy_group.vcf_fleet` is `VCF_FLEET`, `m01_avi` is `M01_AVI`. The prefix says
  where the object belongs: `vcf_*` for the whole fleet, `vcf_fm` / `vcf01_*` for Fleet Management
  components, `m01_*` for the management domain and `w01_*` for workload domain 01.
  `vcf_fleet` (everything: Fleet Management plus both domains) and `vcf_fm` (Fleet Management only)
  are different groups.
- **`nsx_id` is the NSX object ID and is immutable.** Changing it destroys and recreates the object,
  and NSX refuses to delete an object that is still referenced. When an ID must change, give the
  resource `lifecycle { create_before_destroy = true }` so the new object exists before the old one
  is removed.
- **State moves.** When a resource is renamed in code, add a `moved` block so Terraform keeps its
  existing state instead of destroying and recreating it. Run `terraform apply` once to record the
  move, then delete the block.
- **Rule names** read `<source> to <destination>`, with `(In)`, `(Out)`, `(Intra)` and `(Lock Down)`
  suffixes in Application policies. Every policy except "VCF Fleet External" ends with a `(Lock Down)` rule.
  The rules of "VCF Fleet External" and "VCF Fleet Infrastructure" are named after the traffic they allow
  (`Syslog`, `Backup`, `DNS`, ...).
- **Rules list their services explicitly.** Every rule names the exact services it allows
  (for example `HTTPS`, `TCP-4505_4506`) instead of pointing at a bundle of services, so anyone
  reading a rule in the code or in the NSX UI sees the exact ports. Services are not combined into
  composite services for that reason.

## Usage

**1. Clone the repository**

```bash
git clone <repo-url>
cd vcf-mgmt-wld-security
```

**2. Configure variables**

Copy the example values file and populate it with your environment's values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set the IP addresses and VM name prefixes that match your deployment.
The values are grouped into four objects: `external_services`, `fleet`, `m01` and `w01`. Each
attribute is documented in `variables.tf`, and the root module rejects malformed IP addresses,
ranges, CIDR blocks and empty VM names at plan time.

> **Note:** `terraform.tfvars` is excluded from version control by `.gitignore`. Only
> `terraform.tfvars.example` is committed. Terraform loads `terraform.tfvars` automatically; to use a
> differently named file, pass it with `-var-file=<file>`.

Provide the NSX Manager connection through the environment, not through a tfvars file. Values in
a tfvars file override `TF_VAR_*` variables, so a placeholder left in the file breaks the connection:

```bash
export TF_VAR_nsx_manager=nsx.example.com
export TF_VAR_nsx_username=admin
export TF_VAR_nsx_password=...
```

**TLS verification.** Certificate verification is on by default. If your NSX Manager uses a
self-signed certificate (typically a lab), set `nsx_allow_unverified_ssl = true` in your
`terraform.tfvars`. Do not do this in production.

**3. Initialize Terraform**

```bash
terraform init
```

**4. Review the plan**

```bash
terraform plan
```

**5. Apply**

```bash
terraform apply
```

To apply just one module, target it directly — `groups-and-services`, `infrastructure`,
`environment`, and the three `application` modules can be applied in any order
relative to one another, since only `groups-and-services` is a shared dependency:

```bash
terraform apply -target=module.groups_and_services
terraform apply -target=module.infrastructure
terraform apply -target=module.environment
terraform apply -target=module.application_fm
terraform apply -target=module.application_m01
terraform apply -target=module.application_w01
```

## Upgrading from the flat variable layout

Earlier versions used one flat variable per value (`m01_vcenter`, `m01_nsx_manager_a`, ...). They are
now grouped into objects:

| Old variable | New attribute |
|--------------|---------------|
| `dns_server`, `ntp_server`, `dhcp_server`, `ad_server`, `smtp_server`, `bastion_host`, `tools_server`, `backup_server` | `external_services.<same name>` |
| `vcfops01`, `vcfmsvc`, `vcfa`, `vcf_lic`, `vcf_lhub`, `sddc`, `vcfops_cp` | `fleet.<same name>` |
| `vcf01_sspi` | `fleet.sspi` |
| `vcfops_net`, `vcfops_net_cn` | `fleet.ops_net.platform`, `fleet.ops_net.collector` (null if not deployed) |
| hard-coded `172.16.10.28` / `172.16.10.91` | `fleet.vcfa_vip` / `fleet.vcf_lhub_ip` |
| `m01_vcenter`, `w01_vcenter` | `m01.vcenter`, `w01.vcenter` |
| `*_nsx_manager_a/b/c`, `m01_avi_controller_a/b/c` | `m01.nsx_managers`, `w01.nsx_managers`, `m01.avi_controllers` (lists of the VM names that exist) |
| `*_edges`, `*_hosts`, `m01_avi_se_mgmt`, `m01_ssp_svc`, `w01_sup01` | the attribute of the same name inside `m01` / `w01` |
| `w01_avi_controller_a/b/c`, `w01_avi_se_mgmt` | removed together with the Workload Domain Avi Controller policy |
| `w01_sspi_vm`, `w01_ssp_svc` | `w01.ssp.sspi_vm`, `w01.ssp.ssp_svc` (null until SSP is deployed) |

Several resources were also renamed. A deployment whose state was created with the old layout keeps its
resources if you move them (`terraform state mv`, or temporary `moved` blocks) before the first apply:

| Old address (module `groups_and_services` unless noted) | New address |
|--------------------------------------------------------|-------------|
| `nsxt_policy_vm_tags.vm1_tags` / `vm2_tags` / `vm6_tags` / `vm8_tags` / `vm25_tags` / `vm16_tags` | `nsxt_policy_vm_tags.vcfops01` / `vcf_lic` / `vcfops_cp` / `sddc` / `vcf_lhub` / `sspi` |
| `nsxt_policy_vm_tags.vm9_tags`, `vm10_tags`, `vm13_tags` | `m01_vcenter`, `m01_nsx_manager["<vm name>"]`, `m01_avi_controller["<vm name>"]` |
| `nsxt_policy_vm_tags.vm17_tags`, `vm18_tags` | `w01_vcenter`, `w01_nsx_manager["<vm name>"]` |
| `nsxt_policy_group.vcf_f` | `nsxt_policy_group.vcf_fleet` |
| module `environment`: `nsxt_policy_security_policy.vcf_f_environment` | `vcf_fleet_environment` |
| module `environment`: `vcf01_m01_environment`, `vcf01_w01_environment` | `domain["m01"]`, `domain["w01"]` |
| module `infrastructure`: `nsxt_policy_group.dns_svc` / `ntp_svc` / `dhcp_svc` / `ad_svc` | module `groups_and_services`: the same four resource names |

Without the moves, `terraform plan` would destroy and recreate those resources. After the moves, the
plan shows only the rule renames and the other changes listed by the plan.

## How the policies are evaluated

NSX evaluates the distributed firewall categories in this order, and stops at the first rule that
matches a flow: **Emergency, Infrastructure, Environment, Application**, then the default rule.

| Term | Meaning |
|------|---------|
| `ALLOW` / `DROP` | The decision is final. An `ALLOW` in Environment means the flow is **not** checked against the Application policies. |
| `JUMP_TO_APPLICATION` | Skips the remaining Environment rules (including the Environment Lock Down) and evaluates the flow in the Application category. Used for traffic inside a domain. |
| `(In)` / `(Out)` | The direction of an Application rule at the VM it is applied to. |
| `(Intra)` | Traffic between members of the same group. |
| `(Lock Down)` | The last rule of a policy: set to `DROP` and logs everything that was not matched above it. In "VCF Fleet Infrastructure" it is limited to DNS, NTP, DHCP and (when configured) syslog traffic. To run a policy in monitor-only mode first, temporarily set its Lock Down rule to `ALLOW` and review the log. |

Because an Environment `ALLOW` bypasses the Application layer, keep Environment rules as narrow as
the fine-grained Application rules you rely on. Rules are stateful, so only the first packet of a
connection is evaluated and return traffic needs no rule.

**Logging.** Only the Lock Down rules are logged (`logged = true`). The `ALLOW` rules are not, to keep
the logs small. To troubleshoot a flow, set `logged = true` on the relevant rule temporarily, or read
the Lock Down log on the ESXi host (`/var/log/dfwpktlogs.log`).

**Policy sequence numbers.** Infrastructure uses 1. Environment uses 1 (VCF Fleet External), 2 (Fleet
Management), 3 (management domain) and 4 (workload domain 01). Application uses 1-7 (Fleet
Management), 8-10 (management domain) and 11-14 (workload domain 01: 11, 12 and the SSP policy at 14;
13 is free). Keep these ranges apart when you add a policy.

## State management

This configuration uses Terraform's default **local state** (`terraform.tfstate`, git-ignored). The
state records the IDs of every policy, group, service and VM tag, so treat it as sensitive:

- For anything beyond a single-operator lab, store the state in a **remote backend with locking and
  encryption** (for example S3 with DynamoDB or native locking, Azure Storage, or Terraform Cloud/Enterprise)
  so that two people cannot apply at the same time.
- Add the backend as a `backend` block inside the `terraform` block in `versions.tf`, then run
  `terraform init -migrate-state`. Example for S3:

  ```hcl
  terraform {
    backend "s3" {
      bucket       = "<state bucket>"
      key          = "vcf-mgmt-wld-security/terraform.tfstate"
      region       = "<region>"
      encrypt      = true
      use_lockfile = true
    }
  }
  ```

- Never commit state files, and restrict who can read them.

## DFW Policy Overview

The configuration creates three categories of DFW policies scoped to VCF components:

| Category | Policy | Description |
|----------|--------|-------------|
| Infrastructure | VCF Fleet Infrastructure | Allows DNS, NTP, DHCP, AD and (when configured) external syslog traffic; drops and logs the remaining DNS, NTP, DHCP and syslog traffic |
| Environment | VCF Fleet External | Controls inbound access (bastion, tools, VCF Automation portal) and the logging, backup, mail and Broadcom depot traffic of the full VCF fleet |
| Environment | VCF Fleet Management | Controls traffic between fleet management tools and the VCF domains |
| Environment | VCF01 Management Domain | Traffic between the management domain and the rest of the fleet; intra-domain traffic jumps to the Application policies |
| Environment | VCF01 Workload Domain | Same rule set as the management domain for workload domain 01, plus the two Supervisor rules (Supervisor to Workload Domain and back) |
| Application | VCF Operations / Automation / Operations for Networks / Management Services / License / License Hub / SDDC Manager Policies | Component-level rules for VCF Fleet Management applications |
| Application | Management Domain vCenter / Avi / SSP Policies | Component-level rules for management domain (m01) applications |
| Application | Workload Domain 01 vCenter / NSX Policies | Component-level rules for workload domain 01 (w01) applications (the SSP policy exists only when `w01.ssp` is set) |

All policies use `tcp_strict = true` and `stateful = true`. Each policy except "VCF Fleet External" ends with an explicit **Lock Down** rule (`logged = true`) that logs any traffic not matched by the rules above it. All Lock Down rules are `action = "DROP"`, so traffic not allowed by the rules above them is blocked and logged. The "VCF Fleet Infrastructure" Lock Down rule is limited to DNS, NTP, DHCP and (when configured) syslog traffic. To trial a policy in monitor-only mode, temporarily set its Lock Down rule to `ALLOW` and review the log.

## Support and contributing

Report problems and suggest changes through the issues of the repository this configuration is
published in (https://github.com/nnikodimov/vcf-mgmt-wld-security). Before opening a pull request, run
`terraform fmt -recursive` and `terraform init -backend=false && terraform validate`.
