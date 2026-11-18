#!/usr/bin/env python3
"""Discover terraform.tfvars values from VCF Operations, NSX Manager and vCenter.

Starting from a single VCF Operations address, the script finds the management
(m01) and workload (w01) domains, follows them to their NSX Manager and vCenter,
and collects everything that can be read from those APIs. It writes a tfvars file
(grouped as the external_services, fleet, m01 and w01 objects) and reports what it
could not discover. --base may be a file in this format or in the older flat
one-variable-per-line format.

Read-only: only GET requests (plus the login/logout calls) are issued.

Usage:
  scripts/discover-tfvars.py --ops vcfops01.example.com [--insecure] \
      [--base terraform.tfvars.example] [-o terraform.tfvars.local]

Credentials (never passed on the command line; prompted for if not in the env):
  OPS_USERNAME (default admin)                         OPS_PASSWORD
  NSX_USERNAME (default admin)                         NSX_PASSWORD
  VC_USERNAME  (default administrator@vsphere.local)   VC_PASSWORD
The same NSX and vCenter credentials are used for every domain.

The NSX Manager address/credentials for Terraform itself (nsx_manager,
nsx_username, nsx_password) are deliberately NOT written to the output; supply
them with TF_VAR_nsx_manager / TF_VAR_nsx_username / TF_VAR_nsx_password.
"""

import argparse
import getpass
import ipaddress
import json
import os
import re
import socket
import ssl
import sys
import urllib.error
import urllib.parse
import urllib.request

# Order of keys in the generated file (matches terraform.tfvars).
KEY_ORDER = [
    "dns_server", "ntp_server", "dhcp_server", "ad_server", "smtp_server",
    "bastion_host", "tools_server", "backup_server",
    None,
    "vcfops01", "vcfmsvc", "vcfops_net", "vcfa", "vcfa_vip", "vcf_lic", "vcf_lhub", "vcf_lhub_ip",
    None,
    "sddc", "vcfops_cp", "vcfops_net_cn", "vcf01_sspi",
    None,
    "m01_vcenter", "m01_nsx_manager_a", "m01_nsx_manager_b", "m01_nsx_manager_c",
    "m01_avi_controller_a", "m01_avi_controller_b", "m01_avi_controller_c",
    "m01_edges", "m01_hosts", "m01_avi_se_mgmt", "m01_ssp_svc",
    None,
    "w01_vcenter", "w01_nsx_manager_a", "w01_nsx_manager_b", "w01_nsx_manager_c",
    "w01_avi_controller_a", "w01_avi_controller_b", "w01_avi_controller_c",
    "w01_edges", "w01_hosts", "w01_avi_se_mgmt", "w01_ssp_svc", "w01_sspi_vm", "w01_sup01",
]
ALL_KEYS = [k for k in KEY_ORDER if k]
LETTERS = "abc"

# Keys no API in these products exposes; they always come from --base or stay TODO.
NOT_DISCOVERABLE = {
    "vcfa_vip": "the VCF Automation load balancer VIP is not exposed by the queried APIs",
    "vcf_lhub_ip": "the vDefend License Hub additional IP is not exposed by the queried APIs",
    "dhcp_server": "no API exposes the DHCP server",
    "ad_server": "no Active Directory source found in VCF Operations/NSX/vCenter",
    "smtp_server": "SMTP settings are not exposed by the queried APIs",
    "bastion_host": "external host, not known to VCF",
    "tools_server": "external host, not known to VCF",
    "m01_avi_se_mgmt": "Avi Service Engine management network is not exposed by the queried APIs",
    "m01_ssp_svc": "SSP manager IP range is not exposed by the queried APIs",
    "w01_avi_se_mgmt": "Avi Service Engine management network is not exposed by the queried APIs",
    "w01_ssp_svc": "SSP manager IP range is not exposed by the queried APIs",
    "w01_sup01": "Supervisor IP range is not exposed by the queried APIs",
}


class ApiError(Exception):
    pass


class Http:
    def __init__(self, base, insecure):
        self.base = base.rstrip("/")
        self.ctx = ssl.create_default_context()
        if insecure:
            self.ctx.check_hostname = False
            self.ctx.verify_mode = ssl.CERT_NONE

    def call(self, method, path, headers=None, body=None, basic=None, raw=False):
        h = {"Accept": "application/json"}
        h.update(headers or {})
        data = None
        if body is not None:
            data = json.dumps(body).encode()
            h["Content-Type"] = "application/json"
        if basic:
            import base64
            h["Authorization"] = "Basic " + base64.b64encode(
                f"{basic[0]}:{basic[1]}".encode()).decode()
        req = urllib.request.Request(self.base + path, data=data, headers=h, method=method)
        try:
            with urllib.request.urlopen(req, context=self.ctx, timeout=30) as r:
                txt = r.read().decode()
        except urllib.error.HTTPError as e:
            raise ApiError(f"{method} {self.base}{path} -> HTTP {e.code}") from None
        except (urllib.error.URLError, OSError) as e:
            raise ApiError(f"{method} {self.base}{path} -> {getattr(e, 'reason', e)}") from None
        if raw:
            return txt
        return json.loads(txt) if txt.strip() else {}


class Ops(Http):
    def __init__(self, host, user, pw, insecure):
        super().__init__(f"https://{host}", insecure)
        r = self.call("POST", "/suite-api/api/auth/token/acquire",
                      body={"username": user, "password": pw})
        self.token = r["token"]

    def get(self, path):
        return self.call("GET", "/suite-api/api" + path,
                         headers={"Authorization": f"OpsToken {self.token}"})

    def close(self):
        try:
            self.call("POST", "/suite-api/api/auth/token/release",
                      headers={"Authorization": f"OpsToken {self.token}"}, raw=True)
        except ApiError:
            pass

    def domain(self, name):
        r = self.get("/resources?adapterKind=VcfAdapter&resourceKind=VCFDomain&pageSize=100")
        doms = {x["resourceKey"]["name"]: x["identifier"] for x in r.get("resourceList", [])}
        if name not in doms:
            return None, sorted(doms)
        kids = self.get(f"/resources/{doms[name]}/relationships?relationshipType=CHILD")
        out = {}
        for k in kids.get("resourceList", []):
            ak = k["resourceKey"]["adapterKindKey"]
            if ak == "NSXTAdapter":
                out["nsx"] = k["resourceKey"]["name"]
            elif ak == "VMWARE":
                out["vc"] = k["resourceKey"]["name"]
        return out, sorted(doms)

    def collectors(self):
        return self.get("/collectors").get("collector", [])


class Nsx(Http):
    def __init__(self, host, user, pw, insecure):
        super().__init__(f"https://{host}", insecure)
        self.auth = (user, pw)

    def get(self, path):
        return self.call("GET", path, basic=self.auth)

    def vms(self):
        names, cursor = [], ""
        while True:
            r = self.get("/api/v1/fabric/virtual-machines?page_size=1000" + cursor)
            names += [x["display_name"] for x in r.get("results", [])]
            if not r.get("cursor"):
                return names
            cursor = "&cursor=" + r["cursor"]

    def transport_nodes(self, rtype):
        r = self.get("/api/v1/transport-nodes?page_size=1000")
        return [x for x in r.get("results", [])
                if x.get("node_deployment_info", {}).get("resource_type") == rtype
                or x.get("resource_type") == rtype]

    def manager_nodes(self):
        r = self.get("/api/v1/cluster/nodes")
        return sorted(x["display_name"] for x in r.get("results", [])
                      if x.get("appliance_mgmt_listen_addr"))


class Vc(Http):
    def __init__(self, host, user, pw, insecure):
        super().__init__(f"https://{host}", insecure)
        self.sid = self.call("POST", "/api/session", basic=(user, pw))

    def get(self, path):
        return self.call("GET", path, headers={"vmware-api-session-id": self.sid})

    def close(self):
        try:
            self.call("DELETE", "/api/session",
                      headers={"vmware-api-session-id": self.sid}, raw=True)
        except ApiError:
            pass


def short(fqdn):
    return fqdn.split(".")[0]


def resolve(host):
    try:
        ipaddress.ip_address(host)
        return host
    except ValueError:
        pass
    try:
        return socket.gethostbyname(host)
    except OSError:
        return None


def to_range(ips):
    """Collapse IPs to a 'a-b' range (or a single IP). Returns (value, has_gaps)."""
    addrs = sorted({ipaddress.ip_address(i) for i in ips})
    if not addrs:
        return None, False
    if len(addrs) == 1:
        return str(addrs[0]), False
    gaps = int(addrs[-1]) - int(addrs[0]) + 1 != len(addrs)
    return f"{addrs[0]}-{addrs[-1]}", gaps


def read_base(path):
    """Read a --base tfvars file into the flat key space used internally.

    Understands the grouped format (external_services/fleet/m01/w01 objects) and the older
    flat format (one variable per line).
    """
    out = {}
    if not path:
        return out
    stack = []
    with open(path) as f:
        for line in f:
            line = line.rstrip("\n")
            if re.match(r"^\s*#", line):
                continue
            m = re.match(r"^\s*([A-Za-z0-9_]+)\s*=\s*\{\s*(#.*)?$", line)
            if m:
                stack.append(m.group(1))
                continue
            if re.match(r"^\s*\}\s*(#.*)?$", line):
                if stack:
                    stack.pop()
                continue
            m = re.match(r'^\s*([A-Za-z0-9_]+)\s*=\s*\[(.*?)\]\s*(#.*)?$', line)
            if m:
                names = re.findall(r'"([^"]*)"', m.group(2))
                key = ".".join(stack + [m.group(1)])
                for i, n in enumerate(names[:len(LETTERS)]):
                    flat = _flat_list_key(key, i)
                    if flat:
                        out[flat] = n
                continue
            m = re.match(r'^\s*([A-Za-z0-9_]+)\s*=\s*"(.*?)"\s*(#.*)?$', line)
            if m:
                key = ".".join(stack + [m.group(1)])
                out[_flat_key(key)] = m.group(2)
    return out


def _flat_key(key):
    """Grouped attribute path -> flat internal key (flat keys map to themselves)."""
    special = {
        "fleet.sspi": "vcf01_sspi",
        "fleet.ops_net.platform": "vcfops_net",
        "fleet.ops_net.collector": "vcfops_net_cn",
        "w01.ssp.sspi_vm": "w01_sspi_vm",
        "w01.ssp.ssp_svc": "w01_ssp_svc",
    }
    if key in special:
        return special[key]
    head, _, rest = key.partition(".")
    if head == "external_services" or head == "fleet":
        return rest or head
    if head in ("m01", "w01") and rest:
        return f"{head}_{rest}"
    return key


def _flat_list_key(key, i):
    head, _, rest = key.partition(".")
    if head in ("m01", "w01") and rest in ("nsx_managers", "avi_controllers"):
        singular = {"nsx_managers": "nsx_manager", "avi_controllers": "avi_controller"}[rest]
        return f"{head}_{singular}_{LETTERS[i]}"
    return None


class Findings:
    def __init__(self):
        self.vals = {}     # key -> (value, source)
        self.why = {}      # key -> reason it is missing
        self.notes = []

    def set(self, key, value, source):
        self.vals[key] = (value, source)

    def miss(self, key, reason):
        self.why.setdefault(key, reason)

    def note(self, msg):
        self.notes.append(msg)


def pick_all(vms, pattern, exclude=None):
    rx = re.compile(pattern, re.I)
    ex = re.compile(exclude, re.I) if exclude else None
    return sorted(v for v in vms if rx.search(v) and not (ex and ex.search(v)))


def assign_abc(f, prefix, names, source, what):
    for i, letter in enumerate(LETTERS):
        key = f"{prefix}_{letter}"
        if i < len(names):
            f.set(key, names[i], source)
        else:
            f.miss(key, f"{len(names)} of {len(LETTERS)} {what} found")
    if len(names) > len(LETTERS):
        f.note(f"{prefix}: found {len(names)} {what}, only the first {len(LETTERS)} are used: {names}")


def first_prefix(names):
    """'vcfsvc-abc12' -> 'vcfsvc-' (the VM-name prefix the groups match on)."""
    m = re.match(r"^([^-]+-)", names[0]) if names else None
    return m.group(1) if m else None


def discover(args, creds):
    f = Findings()
    clients = []

    try:
        ops = Ops(args.ops, creds["ops"][0], creds["ops"][1], args.insecure)
    except (ApiError, KeyError) as e:
        sys.exit(f"ERROR: cannot log in to VCF Operations ({args.ops}): {e}")
    clients.append(ops)

    dom = {}
    for tag, name in (("m01", args.m01_domain), ("w01", args.w01_domain)):
        info, known = ops.domain(name)
        if info is None:
            if tag == "m01":
                sys.exit(f"ERROR: domain '{name}' not found in VCF Operations. Known: {known}")
            f.note(f"domain '{name}' not found in VCF Operations (known: {known}); w01 keys skipped")
            continue
        if "nsx" not in info or "vc" not in info:
            f.note(f"domain '{name}': could not find both an NSX and a vCenter adapter ({info})")
        dom[tag] = info

    nsxs, vcs = {}, {}
    for tag, info in dom.items():
        try:
            if "nsx" in info:
                nsxs[tag] = Nsx(info["nsx"], creds["nsx"][0], creds["nsx"][1], args.insecure)
                nsxs[tag].get("/api/v1/node/version")
            if "vc" in info:
                vcs[tag] = Vc(info["vc"], creds["vc"][0], creds["vc"][1], args.insecure)
                clients.append(vcs[tag])
        except ApiError as e:
            f.note(f"{tag}: {e}")
    nsx_m, vc_m = nsxs.get("m01"), vcs.get("m01")
    if not nsx_m:
        sys.exit("ERROR: no usable management-domain NSX Manager; cannot continue")

    # ---- VM inventory: the same view Terraform's nsxt_policy_vm lookups use
    vms = nsx_m.vms()
    src_inv = f"NSX {dom['m01']['nsx']} VM inventory"

    def need_vm(key, name, source):
        if name in vms:
            f.set(key, name, source)
        else:
            f.miss(key, f"'{name}' ({source}) is not in the NSX VM inventory")

    # ---- VCF Operations fleet components
    need_vm("vcfops01", short(args.ops), "VCF Operations address")
    # The built-in collector on the VCF Operations node is named "VCF Operations Collector-<node>";
    # anything else is a cloud proxy.
    collectors = [c for c in ops.collectors()
                  if not c.get("name", "").startswith("VCF Operations Collector-")]
    if collectors:
        need_vm("vcfops_cp", short(collectors[0]["name"]), "VCF Operations collectors")
    else:
        hits = pick_all(vms, r"^vcfopscp")
        f.set("vcfops_cp", hits[0], src_inv + " (pattern ^vcfopscp)") if hits else f.miss("vcfops_cp", "no cloud proxy found")

    simple = {
        "sddc": (r"^sddc", None),
        "vcf_lic": (r"^license", None),
        "vcf_lhub": (r"^(m01-)?lh\d", None),
        "vcfops_net": (r"^vrni-platform", None),
        "vcfops_net_cn": (r"^vrni-collector", None),
    }
    for key, (pat, ex) in simple.items():
        hits = pick_all(vms, pat, ex)
        if hits:
            f.set(key, hits[0], f"{src_inv} (pattern {pat})")
            if len(hits) > 1:
                f.note(f"{key}: {len(hits)} VMs match {pat}: {hits}; using {hits[0]}")
        else:
            f.miss(key, f"no VM matches {pat}")
    for key, pat in (("vcfmsvc", r"^vcfsvc-"), ("vcfa", r"^vcfa-")):
        hits = pick_all(vms, pat)
        p = first_prefix(hits)
        if p:
            f.set(key, p, f"{src_inv} (VM name prefix of {len(hits)} VM(s))")
        else:
            f.miss(key, f"no VM matches {pat}")

    # ---- per-domain components
    for tag in ("m01", "w01"):
        if tag not in dom:
            for k in ALL_KEYS:
                if k.startswith(tag + "_"):
                    f.miss(k, f"domain '{tag}' not found")
            continue
        info, nsx_d, vc_d = dom[tag], nsxs.get(tag), vcs.get(tag)
        if "vc" in info:
            need_vm(f"{tag}_vcenter", short(info["vc"]), f"VCF Operations domain {tag} vCenter adapter")
        if nsx_d:
            nodes = nsx_d.manager_nodes()
            assign_abc(f, f"{tag}_nsx_manager", nodes, f"NSX {info['nsx']} cluster nodes", "NSX Manager nodes")
            for letter, n in zip(LETTERS, nodes):
                if n not in vms:
                    f.note(f"{tag}_nsx_manager_{letter}: '{n}' is an NSX node name but not in the VM inventory")
            for what, rtype in (("edges", "EdgeNode"), ("hosts", "HostNode")):
                ips = [i for n in nsx_d.transport_nodes(rtype)
                       for i in n.get("node_deployment_info", {}).get("ip_addresses", [])]
                val, gaps = to_range(ips)
                key = f"{tag}_{what}"
                if val:
                    f.set(key, val, f"NSX {info['nsx']} {rtype} transport nodes ({len(set(ips))})")
                    if gaps:
                        f.note(f"{key}: addresses are not contiguous ({sorted(set(ips))}); "
                               f"emitted min-max range {val}, which includes unused addresses")
                else:
                    f.miss(key, f"NSX {info['nsx']} has no {rtype} transport nodes")
        avi = pick_all(vms, rf"^{tag}-avi", r"-se-|avi-se")
        assign_abc(f, f"{tag}_avi_controller", avi, src_inv + f" (pattern ^{tag}-avi)", "Avi controllers")
        # The management domain's SSPI VM is a VCF01 (fleet-level) component.
        sspi_key, sspi_pat = (("vcf01_sspi", r"^(?:vcf01|m01)-sspi") if tag == "m01"
                              else (f"{tag}_sspi_vm", rf"^{tag}-sspi"))
        sspi = pick_all(vms, sspi_pat)
        if sspi:
            f.set(sspi_key, sspi[0], src_inv + f" (pattern {sspi_pat})")
        else:
            f.miss(sspi_key, f"no VM matches {sspi_pat}")

    # ---- shared infrastructure services
    if vc_m:
        try:
            dns = vc_m.get("/api/appliance/networking/dns/servers").get("servers", [])
        except ApiError:
            dns = []
        if dns:
            f.set("dns_server", dns[0], f"vCenter {dom['m01']['vc']} appliance DNS")
        try:
            ntp = vc_m.get("/api/appliance/ntp")
            ntp = ntp if isinstance(ntp, list) else ntp.get("servers", [])
        except ApiError:
            ntp = []
        if ntp:
            ip = resolve(ntp[0])
            if ip:
                f.set("ntp_server", ip, f"vCenter {dom['m01']['vc']} appliance NTP ({ntp[0]})")
            else:
                f.miss("ntp_server", f"NTP server '{ntp[0]}' does not resolve from this host")
    if "dns_server" not in f.vals:
        try:
            dns = nsx_m.get("/api/v1/node/network/name-servers").get("name_servers", [])
            if dns:
                f.set("dns_server", dns[0], f"NSX {dom['m01']['nsx']} node DNS")
        except ApiError:
            pass
    if "ntp_server" not in f.vals and "ntp_server" not in f.why:
        try:
            ntp = nsx_m.get("/api/v1/node/services/ntp")["service_properties"]["servers"]
            ip = resolve(ntp[0]) if ntp else None
            if ip:
                f.set("ntp_server", ip, f"NSX {dom['m01']['nsx']} node NTP ({ntp[0]})")
        except (ApiError, KeyError):
            pass

    try:
        bk = nsx_m.get("/api/v1/cluster/backups/config")
        srv = bk.get("remote_file_server", {}).get("server") if bk.get("backup_enabled") else None
    except ApiError:
        srv = None
    if srv:
        ip = resolve(srv)
        if ip:
            f.set("backup_server", ip, f"NSX {dom['m01']['nsx']} backup target ({srv})")
            f.note(f"backup_server: taken from the NSX backup target '{srv}'; if that is SDDC Manager "
                   f"rather than your external backup host, correct it")
        else:
            f.miss("backup_server", f"backup target '{srv}' does not resolve from this host")

    for k, why in NOT_DISCOVERABLE.items():
        if k not in f.vals:
            f.miss(k, why)
    for c in clients:
        if hasattr(c, "close"):
            c.close()
    return f


def render(f, base, args):
    """Render the grouped tfvars text. Returns (text, stats, diffs)."""
    stats = {"discovered": 0, "base": 0, "todo": 0}
    diffs = []
    state = {}   # flat key -> ("d"|"b"|"t", value, comment)

    for key in ALL_KEYS:
        if key in f.vals:
            val, src = f.vals[key]
            state[key] = ("d", val, f"discovered: {src}")
            stats["discovered"] += 1
            if key in base and base[key] != val:
                diffs.append((key, base[key], val))
        elif key in base:
            state[key] = ("b", base[key], f'NOT DISCOVERED ({f.why.get(key, "unknown")}); kept from base')
            stats["base"] += 1
        else:
            state[key] = ("t", None, f'TODO: NOT DISCOVERED ({f.why.get(key, "unknown")})')
            stats["todo"] += 1

    def scalar(indent, attr, key):
        kind, val, why = state[key]
        if kind == "t":
            return [f'{indent}# {attr} = ""  # {why}']
        return [f'{indent}{attr} = "{val}"  # {why}']

    def node_list(indent, attr, prefix, discovered_only=False):
        """List of VM names: those discovered, else (unless discovered_only) the base names."""
        keys = [f"{prefix}_{c}" for c in LETTERS]
        found = [state[k] for k in keys if state[k][0] == "d"]
        if found:
            items, why = [s[1] for s in found], found[0][2]
        elif discovered_only:
            return [f"{indent}{attr} = []  # none discovered; add VM names when deployed"]
        else:
            kept = [state[k] for k in keys if state[k][0] == "b"]
            if not kept:
                return [f'{indent}# {attr} = []  # TODO: NOT DISCOVERED']
            items, why = [s[1] for s in kept], kept[0][2]
        return [f'{indent}{attr} = [{", ".join(chr(34) + n + chr(34) for n in items)}]  # {why}']

    L = [
        "# Generated by scripts/discover-tfvars.py -- review before use.",
        f"# Source: VCF Operations {args.ops}"
        + (f"; fallback values from {args.base}" if args.base else ""),
        "# nsx_manager / nsx_username / nsx_password are intentionally omitted:",
        "#   export TF_VAR_nsx_manager=... TF_VAR_nsx_username=... TF_VAR_nsx_password=...",
        "# Add nsx_allow_unverified_ssl = true below if your NSX Manager uses a self-signed certificate.",
        "",
        "external_services = {",
    ]
    for k in ["dns_server", "ntp_server", "dhcp_server", "ad_server", "smtp_server",
              "bastion_host", "tools_server", "backup_server"]:
        L += scalar("  ", k, k)
    L += ["}", "", "fleet = {"]
    for attr, k in [("vcfops01", "vcfops01"), ("vcfmsvc", "vcfmsvc"), ("vcfa", "vcfa"), ("vcfa_vip", "vcfa_vip"),
                    ("vcf_lic", "vcf_lic"), ("vcf_lhub", "vcf_lhub"), ("vcf_lhub_ip", "vcf_lhub_ip"),
                    ("sddc", "sddc"), ("vcfops_cp", "vcfops_cp"), ("sspi", "vcf01_sspi")]:
        L += scalar("  ", attr, k)
    if state["vcfops_net"][0] == "d" and state["vcfops_net_cn"][0] == "d":
        L += ["  ops_net = {"]
        L += scalar("    ", "platform", "vcfops_net") + scalar("    ", "collector", "vcfops_net_cn") + ["  }"]
    else:
        L += ["  ops_net = null  # VCF Operations for Networks not discovered; set { platform, collector } when deployed"]
    L += ["}", "", "m01 = {"]
    L += scalar("  ", "vcenter", "m01_vcenter")
    L += node_list("  ", "nsx_managers", "m01_nsx_manager")
    L += node_list("  ", "avi_controllers", "m01_avi_controller", discovered_only=True)
    for attr in ["edges", "hosts", "avi_se_mgmt", "ssp_svc"]:
        L += scalar("  ", attr, f"m01_{attr}")
    L += ["}", "", "w01 = {"]
    L += scalar("  ", "vcenter", "w01_vcenter")
    L += node_list("  ", "nsx_managers", "w01_nsx_manager")
    L += node_list("  ", "avi_controllers", "w01_avi_controller", discovered_only=True)
    for attr in ["edges", "hosts", "avi_se_mgmt", "sup01"]:
        L += scalar("  ", attr, f"w01_{attr}")
    if state["w01_sspi_vm"][0] == "d" and state["w01_ssp_svc"][0] != "t":
        L += ["  ssp = {"] + scalar("    ", "sspi_vm", "w01_sspi_vm") + scalar("    ", "ssp_svc", "w01_ssp_svc") + ["  }"]
    else:
        L += ["  ssp = null  # SSP not discovered on w01; set { sspi_vm, ssp_svc } once it is deployed"]
    L += ["}"]
    return "\n".join(L) + "\n", stats, diffs


def get_creds():
    def cred(prefix, default_user):
        user = os.environ.get(f"{prefix}_USERNAME", default_user)
        pw = os.environ.get(f"{prefix}_PASSWORD")
        if not pw:
            if not sys.stdin.isatty():
                sys.exit(f"ERROR: {prefix}_PASSWORD is not set and there is no terminal to prompt on")
            pw = getpass.getpass(f"{prefix} password for {user}: ")
        return user, pw
    return {"ops": cred("OPS", "admin"), "nsx": cred("NSX", "admin"),
            "vc": cred("VC", "administrator@vsphere.local")}


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    p.add_argument("--ops", required=True, help="VCF Operations FQDN or IP")
    p.add_argument("--m01-domain", default="m01", help="management domain name in VCF Operations")
    p.add_argument("--w01-domain", default="w01", help="workload domain name in VCF Operations")
    p.add_argument("--base", help="existing tfvars; used as fallback for undiscoverable keys and to report differences")
    p.add_argument("-o", "--output", help="write to this file instead of stdout")
    p.add_argument("--insecure", action="store_true", help="do not verify TLS certificates (self-signed lab)")
    args = p.parse_args()

    base = read_base(args.base)
    f = discover(args, get_creds())
    text, stats, diffs = render(f, base, args)
    if args.output:
        fd = os.open(args.output, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
        with os.fdopen(fd, "w") as out:
            out.write(text)
    else:
        sys.stdout.write(text)

    err = sys.stderr
    print(f"\n== {stats['discovered']} discovered, {stats['base']} kept from base, "
          f"{stats['todo']} TODO ==", file=err)
    for n in f.notes:
        print(f"NOTE: {n}", file=err)
    if diffs:
        print("\nDiscovered values that differ from --base:", file=err)
        for k, old, new in diffs:
            print(f"  {k}: base={old!r} discovered={new!r}", file=err)
    if args.output:
        print(f"\nWrote {args.output}", file=err)


if __name__ == "__main__":
    main()
