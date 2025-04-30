#Aria Suite

data "nsxt_policy_segment" "aria_x_ans" {
  display_name = var.aria_x_ans
}

data "nsxt_policy_segment" "aria_ans" {
  display_name = var.aria_ans
}

resource "nsxt_policy_group" "aria_suite" {
  nsx_id       = "ARIA_SUITE"
  display_name = "ARIA_SUITE"

  criteria {
    path_expression {
      member_paths = [data.nsxt_policy_segment.aria_x_ans.path,data.nsxt_policy_segment.aria_ans.path]
    }
  }
}