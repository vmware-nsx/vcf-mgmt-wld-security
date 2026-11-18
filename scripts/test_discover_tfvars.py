"""Unit tests for scripts/discover-tfvars.py (offline; no VCF/NSX/vCenter access needed).

Run from the repository root:  python3 -m unittest discover -s scripts
"""
import importlib.util
import os
import tempfile
import types
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

spec = importlib.util.spec_from_file_location("discover", os.path.join(HERE, "discover-tfvars.py"))
discover = importlib.util.module_from_spec(spec)
spec.loader.exec_module(discover)

ARGS = types.SimpleNamespace(ops="vcfops.example", base="base.tfvars")


def findings(**discovered):
    f = discover.Findings()
    for k, v in discovered.items():
        f.set(k, v, "test")
    for k, why in discover.NOT_DISCOVERABLE.items():
        if k not in f.vals:
            f.miss(k, why)
    return f


def write(text):
    fd, path = tempfile.mkstemp(suffix=".tfvars")
    with os.fdopen(fd, "w") as out:
        out.write(text)
    return path


class ReadBaseTests(unittest.TestCase):
    def test_example_file_maps_to_flat_keys(self):
        base = discover.read_base(os.path.join(ROOT, "terraform.tfvars.example"))
        self.assertEqual(base["dns_server"], "192.168.110.10")
        self.assertEqual(base["vcf01_sspi"], "vcf01-sspi")
        self.assertEqual(base["vcfops_net"], "vrni-platform")
        self.assertEqual(base["vcfops_net_cn"], "vrni-collector")
        self.assertEqual(base["m01_nsx_manager_a"], "m01-nsx01a")
        self.assertEqual(base["m01_nsx_manager_c"], "m01-nsx01c")
        self.assertEqual(base["w01_avi_controller_b"], "w01-avi01b")
        self.assertEqual(base["m01_ssp_svc"], "172.16.21.2-172.16.21.33")
        self.assertEqual(base["w01_sup01"], "172.16.10.101-172.16.10.110")
        self.assertNotIn("w01_sspi_vm", base)  # w01.ssp is null in the example

    def test_legacy_flat_format_is_still_read(self):
        path = write('m01_vcenter = "m01-vc01"  # comment\nvcf01_sspi = "sspi"\nw01_sup01 = "10.0.0.1-10.0.0.9"\n')
        base = discover.read_base(path)
        os.remove(path)
        self.assertEqual(base["m01_vcenter"], "m01-vc01")
        self.assertEqual(base["vcf01_sspi"], "sspi")
        self.assertEqual(base["w01_sup01"], "10.0.0.1-10.0.0.9")

    def test_missing_file_argument_returns_empty(self):
        self.assertEqual(discover.read_base(None), {})


class RenderTests(unittest.TestCase):
    def render(self, f, base=None):
        return discover.render(f, base or {}, ARGS)

    def test_optional_components_are_null_when_not_discovered(self):
        base = discover.read_base(os.path.join(ROOT, "terraform.tfvars.example"))
        text, _, _ = self.render(findings(m01_vcenter="m01-vc01"), base)
        self.assertIn("ops_net = null", text)
        self.assertIn("ssp = null", text)
        self.assertNotIn("vrni-platform", text)  # never copied from base when not discovered

    def test_discovered_ops_net_and_w01_ssp_are_emitted_as_objects(self):
        f = findings(vcfops_net="vrni-p", vcfops_net_cn="vrni-c", w01_sspi_vm="w01-sspi", w01_ssp_svc="10.1.1.1-10.1.1.9")
        text, _, _ = self.render(f)
        self.assertIn("ops_net = {", text)
        self.assertIn('platform = "vrni-p"', text)
        self.assertIn("ssp = {", text)
        self.assertIn('sspi_vm = "w01-sspi"', text)

    def test_node_lists_use_only_discovered_nodes(self):
        f = findings(m01_nsx_manager_a="m01-nsx01a", m01_avi_controller_a="m01-avi-0", m01_avi_controller_b="m01-avi-1")
        text, _, _ = self.render(f, {"m01_nsx_manager_b": "stale-from-base"})
        self.assertIn('nsx_managers = ["m01-nsx01a"]', text)
        self.assertIn('avi_controllers = ["m01-avi-0", "m01-avi-1"]', text)
        self.assertNotIn("stale-from-base", text)

    def test_no_avi_controllers_discovered_gives_empty_list(self):
        text, _, _ = self.render(findings(), {"w01_avi_controller_a": "w01-avi01a"})
        self.assertIn("avi_controllers = []", text)

    def test_base_values_are_kept_and_counted(self):
        base = {"dhcp_server": "192.168.110.10"}
        text, stats, _ = self.render(findings(), base)
        self.assertIn('dhcp_server = "192.168.110.10"', text)
        self.assertEqual(stats["base"], 1)

    def test_discovered_value_differing_from_base_is_reported(self):
        _, _, diffs = self.render(findings(m01_vcenter="new"), {"m01_vcenter": "old"})
        self.assertEqual(diffs, [("m01_vcenter", "old", "new")])

    def test_output_is_grouped_and_never_contains_nsx_credentials(self):
        text, _, _ = self.render(findings())
        for block in ("external_services = {", "fleet = {", "m01 = {", "w01 = {"):
            self.assertIn(block, text)
        import re
        self.assertIsNone(re.search(r"^\s*nsx_(manager|username|password)\s*=", text, re.M))

    def test_rendered_file_reads_back_to_the_same_values(self):
        f = findings(vcfops01="vcfops01", m01_vcenter="m01-vc01", m01_nsx_manager_a="m01-nsx01a",
                     m01_edges="172.16.10.61-172.16.10.62", w01_hosts="172.16.11.15-172.16.11.16")
        text, _, _ = self.render(f)
        path = write(text)
        back = discover.read_base(path)
        os.remove(path)
        self.assertEqual(back["vcfops01"], "vcfops01")
        self.assertEqual(back["m01_nsx_manager_a"], "m01-nsx01a")
        self.assertEqual(back["m01_edges"], "172.16.10.61-172.16.10.62")
        self.assertEqual(back["w01_hosts"], "172.16.11.15-172.16.11.16")


if __name__ == "__main__":
    unittest.main()
