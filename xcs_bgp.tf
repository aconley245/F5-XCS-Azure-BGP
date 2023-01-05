variable "xcs_bgp_name" {
  type        = string
  description = "Name for the XCS CE Site Local Inside interface name"
  default     = "my-bgp"
}
variable "xcs_bgp_peer1" {
  type        = string
  description = "Name for the XCS CE Site Local Inside interface name"
  default     = "azure-rs1"
}
variable "xcs_bgp_peer2" {
  type        = string
  description = "Name for the XCS CE Site Local Inside interface name"
  default     = "azure-rs2"
}

resource "volterra_bgp" "azure_ce_bgp" {
  name      = var.xcs_bgp_name
  namespace = "system"

  bgp_parameters {
    asn                = var.azure_bgp_peer_asn
    bgp_router_id_type = "bgp_router_id_from_interface"
    local_address      = true
  }

  peers {
    metadata {
      disable = false
      name    = var.xcs_bgp_peer1
    }

    passive_mode_disabled = true
    target_service        = "frr"

    external {
      asn     = "65515"
      address = cidrhost(azurerm_subnet.routeserver.address_prefixes[0], 4)
      port    = "179"
      interface {
        tenant    = var.xcs_tenant
        namespace = volterra_network_interface.sli.namespace
        name      = volterra_network_interface.sli.name
      }
    }
  }
  peers {
    metadata {
      disable = false
      name    = var.xcs_bgp_peer2
    }

    passive_mode_disabled = true
    target_service        = "frr"

    external {
      asn     = "65515"
      address = cidrhost(azurerm_subnet.routeserver.address_prefixes[0], 5)
      port    = "179"
      interface {
        tenant    = var.xcs_tenant
        namespace = volterra_network_interface.sli.namespace
        name      = volterra_network_interface.sli.name
      }
    }
  }


  where {
    // One of the arguments from this list "virtual_site site" must be set

    site {
      network_type = "virtual_network_site_local"

      ref {
        name      = volterra_azure_vnet_site.f5example.name
        namespace = "system"
        tenant    = var.xcs_tenant
      }
    }
  }
}