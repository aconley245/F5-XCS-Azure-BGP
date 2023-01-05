variable "azure_resource_group" {
  type        = string
  description = "Azure Resource Group Name"
}
variable "azure_region" {
  type        = string
  description = "Azure Location Name for example 'West US 2'"
}
variable "azure_vnet_name" {
  type        = string
  description = "Azure Virtual Network Name"
}
variable "azure_vnet_address_space" {
  type        = string
  description = "Azure Supernet to use for the Virtual Network"
}
variable "azure_route_server_subnet" {
  type        = string
  description = "Azure subnet to use for the Route Server, must be at least a /27"
}
variable "xcs_ce_outside_subnet" {
  type        = string
  description = "Azure subnet to use for the XCS CE outside interface"
}
variable "xcs_ce_inside_subnet" {
  type        = string
  description = "Azure subnet to use for the XCS CE inside interface"
}
variable "azure_route_server_pip_name" {
  type        = string
  description = "Azure name for the Public IP used to manage the Route Server"
}
variable "azure_route_server_name" {
  type        = string
  description = "Azure Route Server Name"
}
variable "xcs_ce_inside_subnet_name" {
  type        = string
  description = "Subnet name for CE inside interface"
}

variable "xcs_ce_outside_subnet_name" {
  type        = string
  description = "Subnet name for CE outside interface"
}

resource "azurerm_resource_group" "f5example" {
  name     = var.azure_resource_group
  location = var.azure_region
}

resource "azurerm_virtual_network" "f5example" {
  name                = var.azure_vnet_name
  address_space       = [var.azure_vnet_address_space]
  resource_group_name = azurerm_resource_group.f5example.name
  location            = azurerm_resource_group.f5example.location
}

resource "azurerm_subnet" "routeserver" {
  name                 = "RouteServerSubnet"
  virtual_network_name = azurerm_virtual_network.f5example.name
  resource_group_name  = azurerm_resource_group.f5example.name
  address_prefixes     = [var.azure_route_server_subnet]
}

resource "azurerm_subnet" "ceinside" {
  name                 = var.xcs_ce_inside_subnet_name
  virtual_network_name = azurerm_virtual_network.f5example.name
  resource_group_name  = azurerm_resource_group.f5example.name
  address_prefixes     = [var.xcs_ce_inside_subnet]
}

resource "azurerm_subnet" "ceoutside" {
  name                 = var.xcs_ce_outside_subnet_name
  virtual_network_name = azurerm_virtual_network.f5example.name
  resource_group_name  = azurerm_resource_group.f5example.name
  address_prefixes     = [var.xcs_ce_outside_subnet]
}

resource "azurerm_public_ip" "f5example" {
  name                = var.azure_route_server_pip_name
  resource_group_name = azurerm_resource_group.f5example.name
  location            = azurerm_resource_group.f5example.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_route_server" "f5example" {
  name                             = var.azure_route_server_name
  resource_group_name              = azurerm_resource_group.f5example.name
  location                         = azurerm_resource_group.f5example.location
  sku                              = "Standard"
  public_ip_address_id             = azurerm_public_ip.f5example.id
  subnet_id                        = azurerm_subnet.routeserver.id
  branch_to_branch_traffic_enabled = true
}