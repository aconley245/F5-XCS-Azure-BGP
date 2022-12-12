variable "azure_bgp_peer_name" {
  type        = string
  description = "Azure BGP Peer device name"
}
variable "azure_bgp_peer_asn" {
  type        = string
  description = "Azure BGP Peer device Autonomous System Number"
}
variable "azure_bgp_peer_ip" {
  type        = string
  description = "Azure BGP Peer device IP address"
}
resource "azurerm_route_server_bgp_connection" "f5example" {
  name            = var.azure_bgp_peer_name
  route_server_id = azurerm_route_server.f5example.id
  peer_asn        = var.azure_bgp_peer_asn
  peer_ip         = var.azure_bgp_peer_ip
}