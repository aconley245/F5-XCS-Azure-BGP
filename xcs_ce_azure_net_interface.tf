variable "xcs_ce_sli_name" {
  type        = string
  description = "Name for the XCS CE Site Local Inside interface name"
}

resource "volterra_network_interface" "sli" {
  name      = var.xcs_ce_sli_name
  namespace = "system"

  ethernet_interface {
    dhcp_client      = true
    device           = "eth1"
    not_primary      = true
    monitor_disabled = true
  }
  dedicated_interface {
    device           = "eth1"
    not_primary      = true
    monitor_disabled = true
  }
}