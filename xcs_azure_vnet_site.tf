variable "xcs_azure_site_name" {
  type        = string
  description = "Name for the XCS CE site"
}
variable "xcs_azure_cred_name" {
  type        = string
  description = "Name of the XCS credentials to use to deploy the CE"
}
variable "xcs_tenant" {
  type        = string
  description = "XCS Tenant Name"
}
variable "xcs_azure_rsg" {
  type        = string
  description = "Azure Resource Group to deploy CE into, must be a new RSG"
}
resource "volterra_azure_vnet_site" "f5example" {
  name      = var.xcs_azure_site_name
  namespace = "system"

  default_blocked_services = true

  azure_cred {
    name      = var.xcs_azure_cred_name
    namespace = "system"
    tenant    = var.xcs_tenant
  }

  logs_streaming_disabled = true

  azure_region   = azurerm_resource_group.f5example.location
  resource_group = var.xcs_azure_rsg

  disk_size    = 80
  machine_type = "Standard_D3_v2"

  ingress_egress_gw {
    azure_certified_hw      = "azure-byol-multi-nic-voltmesh"
    no_dc_cluster_group     = true
    no_forward_proxy        = true
    no_global_network       = true
    sm_connection_public_ip = true
    not_hub                 = true
    no_network_policy       = true

    inside_static_routes {
      static_route_list {
        custom_static_route {
          subnets {
            ipv4 {
              prefix = split("/", azurerm_subnet.routeserver.address_prefixes[0])[0]
              plen   = split("/", azurerm_subnet.routeserver.address_prefixes[0])[1]
            }
          }
          nexthop {
            type = "NEXT_HOP_USE_CONFIGURED"
            nexthop_address {
              ipv4 {
                // Sets the next hop to the first IP on the CE inside subnet
                addr = cidrhost(azurerm_subnet.ceinside.address_prefixes[0], 1)
              }
            }
            interface {
              tenant    = var.xcs_tenant
              namespace = "system"
              name      = volterra_network_interface.sli.name
            }
          }
          labels = {}
          attrs  = ["ROUTE_ATTR_INSTALL_HOST", "ROUTE_ATTR_INSTALL_FORWARDING"]
        }
      }
    }

    az_nodes {
      azure_az = "1"
      inside_subnet {
        subnet {
          subnet_name         = azurerm_subnet.ceinside.name
          subnet_resource_grp = azurerm_resource_group.f5example.name
        }
      }
      outside_subnet {
        subnet {
          subnet_name         = azurerm_subnet.ceoutside.name
          subnet_resource_grp = azurerm_resource_group.f5example.name
        }
      }
    }

    no_outside_static_routes = true
  }

  vnet {
    existing_vnet {
      vnet_name      = azurerm_virtual_network.f5example.name
      resource_group = azurerm_resource_group.f5example.name

    }
  }
  no_worker_nodes = true
}

// Apply the Azure VNet Site
resource "volterra_tf_params_action" "apply_azure_vnet" {
  site_name        = volterra_azure_vnet_site.f5example.name
  site_kind        = "azure_vnet_site"
  action           = "apply"
  wait_for_action  = true
  ignore_on_update = true
}