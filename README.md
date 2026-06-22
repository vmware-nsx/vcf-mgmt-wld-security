# Securing the VMware Cloud Foundation management domain with VMware vDefend

Terraform configuration to automate the deployment of vDefend Distributed Firewall (DFW) policies that secure VMware Cloud Foundation (VCF) management components, including VCF Fleet, VCF Fleet management service, SDDC Manager, vCenter Servers, NSX Managers, vDefend Security Services Platfrom, Avi Load Balancer, etc.

## Disclaimer

This configuration is provided as a reference example of how to quickly secure VCF management components. You are solely responsible for reviewing, adapting, and validating it for your own environment before applying it in production.

## Applicable Versions

| Component | Version |
|-----------|---------|
| VMware Cloud Foundation | 9.1.x |
| NSX Terraform Provider | Latest |

## Prerequisites

- VCF 9.1.x deployment with at least one management domain and one workload domain
- NSX Manager accessible from the Terraform host
- **NSX on DVPGs** enabled on all vSphere clusters whose VMs should be protected
- Terraform CLI installed on the host running these configurations
- NSX Enterprise Administrator credentials

## Repository Structure

| File | Description |
|------|-------------|
| `main.tf` | Terraform provider configuration |
| `variables.tf` | Input variable declarations |
| `terraform.tfvars` | Variable values (copy and edit before use) |
| `services.tf` | NSX service and context profile definitions |
| `groups-vcf_fm.tf` | NSX groups for VCF Fleet Management components |
| `groups-vcf01_m01.tf` | NSX groups for management domain (m01) components |
| `groups-vcf01_w01.tf` | NSX groups for workload domain 01 (w01) components |
| `groups-vcf_ext.tf` | NSX groups for external infrastructure services |
| `dfw-policy-infrastructure.tf` | DFW Infrastructure category policy |
| `dfw-policy-environment.tf` | DFW Environment category policies |

## Usage

**1. Clone the repository**

```bash
git clone <repo-url>
cd vcf-mgmt-wld-security
```

**2. Configure variables**

Copy the example values file and populate it with your environment's values:

```bash
cp terraform.tfvars terraform.tfvars.local
```

Edit `terraform.tfvars.local` and set the NSX Manager address, credentials, IP addresses, and VM name prefixes that match your deployment.

> **Note:** `terraform.tfvars` is excluded from version control by `.gitignore` to prevent accidental credential exposure.

**3. Initialize Terraform**

```bash
terraform init
```

**4. Review the plan**

```bash
terraform plan -var-file=terraform.tfvars.local
```

**5. Apply**

```bash
terraform apply -var-file=terraform.tfvars.local
```

## DFW Policy Overview

The configuration creates two categories of DFW policies scoped to VCF components:

| Category | Policy | Description |
|----------|--------|-------------|
| Infrastructure | VCF Infrastructure Policy | Allows DNS, NTP, DHCP, AD, and syslog traffic; drops anything else |
| Environment | VCF Fleet Environment | Controls inbound access and outbound backup/mail/depot traffic for the full VCF fleet |
| Environment | VCF Fleet Management Environment | Controls traffic between fleet management tools and VCF domains |
| Environment | VCF01 Management Domain Environment | Intra-domain rules and a default deny for the management domain |
| Environment | VCF01 Workload Domain 01 Environment | Intra-domain rules and a default deny for workload domain 01 |

All policies use `tcp_strict = true` and `stateful = true`. Each Environment policy ends with an explicit **Lock Down** (DROP + log) rule to enforce a default-deny posture.
