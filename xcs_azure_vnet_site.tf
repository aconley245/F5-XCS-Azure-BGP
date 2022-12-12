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

resource "volterra_azure_vnet_site" "f5example" {
  name      = var.xcs_azure_site_name
  namespace = "system"

  // One of the arguments from this list "default_blocked_services blocked_services" must be set
  default_blocked_services = true

  // One of the arguments from this list "azure_cred" must be set

  azure_cred {
    name      = var.xcs_azure_cred_name
    namespace = "system"
    tenant    = var.xcs_tenant
  }
  // One of the arguments from this list "logs_streaming_disabled log_receiver" must be set
  logs_streaming_disabled = true
  // One of the arguments from this list "azure_region alternate_region" must be set
  azure_region   = "eastus"
  resource_group = "aconley-xcs-rg"

  // One of the arguments from this list "voltstack_cluster_ar ingress_gw ingress_egress_gw voltstack_cluster ingress_gw_ar ingress_egress_gw_ar" must be set

  ingress_egress_gw_ar {
    azure_certified_hw = "azure-byol-multi-nic-voltmesh"

    // One of the arguments from this list "no_dc_cluster_group dc_cluster_group_outside_vn dc_cluster_group_inside_vn" must be set
    no_dc_cluster_group = true

    // One of the arguments from this list "no_forward_proxy active_forward_proxy_policies forward_proxy_allow_all" must be set
    no_forward_proxy = true

    // One of the arguments from this list "no_global_network global_network_list" must be set
    no_global_network = true

    // One of the arguments from this list "hub not_hub" must be set

    hub {
      // One of the arguments from this list "express_route_enabled express_route_disabled" must be set
      express_route_disabled = true

      spoke_vnets {
        labels = {
          "key1" = "value1"
        }

        // One of the arguments from this list "auto manual" must be set
        auto = true

        vnet {
          resource_group = var.azure_resource_group
          vnet_name      = var.azure_vnet_name
        }
      }
    }
    // One of the arguments from this list "no_inside_static_routes inside_static_routes" must be set
    inside_static_routes {
      static_route_list {
        custom_static_route {
          subnets {
            ipv4 {
              prefix = "10.100.0.0"
              plen   = "24"
            }
          }
          nexthop {
            type = "NEXT_HOP_USE_CONFIGURED"
            nexthop_address {
              ipv4 {
                addr = "10.100.1.1"
              }
            }
            interface {
              tenant    = "f5-amer-ent-qyyfhhfj"
              namespace = "system"
              name      = "aconley-azure-inside"
            }
          }
          labels = {}
          attrs  = ["ROUTE_ATTR_INSTALL_HOST", "ROUTE_ATTR_INSTALL_FORWARDING"]
        }
      }
    }
    // One of the arguments from this list "active_network_policies active_enhanced_firewall_policies no_network_policy" must be set
    no_network_policy = true
    node {
      fault_domain = "1"

      inside_subnet {
        // One of the arguments from this list "subnet_param subnet" must be set

        subnet {
          subnet_name = "CEInsideSubnet"
          subnet_resource_grp = "aconley-transit-rg"
        }
      }

      node_number = "1"

      outside_subnet {
        // One of the arguments from this list "subnet_param subnet" must be set

        subnet {
          subnet_name = "CEOutsideSubnet"
          subnet_resource_grp = "aconley-transit-rg"
        }
      }

      update_domain = "1"
    }
    // One of the arguments from this list "no_outside_static_routes outside_static_routes" must be set
    no_outside_static_routes = true
    // One of the arguments from this list "sm_connection_public_ip sm_connection_pvt_ip" must be set
    sm_connection_public_ip = true
  }
  vnet {
    // One of the arguments from this list "new_vnet existing_vnet" must be set

    existing_vnet {
      // One of the arguments from this list "name autogenerate" must be set
      vnet_name = var.azure_vnet_name
      #primary_ipv4 = var.azure_vnet_address_space
      resource_group = var.azure_resource_group

    }
  }
  // One of the arguments from this list "total_nodes no_worker_nodes nodes_per_az" must be set
  total_nodes = "1"
}