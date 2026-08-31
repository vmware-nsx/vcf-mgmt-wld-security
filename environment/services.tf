data "nsxt_policy_service" "https" {
  display_name = "HTTPS"
}

data "nsxt_policy_service" "ssh" {
  display_name = "SSH"
}

data "nsxt_policy_service" "icmp_all" {
  display_name = "ICMP ALL"
}

data "nsxt_policy_service" "icmp_echo" {
  display_name = "ICMP Echo Request"
}

data "nsxt_policy_service" "rdp" {
  display_name = "RDP"
}

data "nsxt_policy_service" "ftp" {
  display_name = "FTP"
}

data "nsxt_policy_service" "smtp" {
  display_name = "SMTP"
}

data "nsxt_policy_service" "smtp_tls" {
  display_name = "SMTP_TLS"
}
