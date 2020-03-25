# Network configuration for spoke vnets in a hub and spoke architecture. 
# https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke

# Random resource for reference

resource "random_id" "randomId" {
    byte_length = 8
}

# Create resource group

resource "azurerm_resource_group" "rg" {
  name     = "${var.context_short_name}-Network-${var.environment_short_name}-RG"
  location = var.location
  tags     = var.tags
}

# Create VNET

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.context_short_name}Services-${var.environment_short_name}-VNET"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_address_space]
  dns_servers         = var.dns_servers
  tags = var.tags
}

# Create NSGs

resource "azurerm_network_security_group" "nsgs" {
  for_each            = var.subnets
  name                = "${var.context_short_name}-${each.key}-${var.environment_short_name}-NSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = var.tags
}

# Create Subnets

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = each.value
}

# Create baseline security rules

resource "azurerm_network_security_rule" "allowmanagement" {
  for_each                    = var.subnets
  name                        = "AllowManagementInBound"
  priority                    = 4094
  direction                   = "inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_ranges     = [
    "3389",
    "22",
    "5985",
    "5986",
  ]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgs[each.key].name
}

resource "azurerm_network_security_rule" "allowloadbalancer" {
  for_each                    = var.subnets
  name                        = "AllowAzureLoadBalancerInBound"
  priority                    = 4095
  direction                   = "inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgs[each.key].name
}

resource "azurerm_network_security_rule" "denyinbound" {
  for_each                    = var.subnets
  name                        = "DenyAllInBound"
  priority                    = 4096
  direction                   = "inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsgs[each.key].name
}

# Associated NSGs to Subnets

resource "azurerm_subnet_network_security_group_association" "assocnsg" {
  for_each                  = var.subnets
  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsgs[each.key].id
}

# Create Route Tables.

resource "azurerm_route_table" "default" {
  name                          = "${var.context_short_name}-Default-${var.environment_short_name}-RT"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = true

  dynamic "route" {
  for_each       = var.routes

    content {
      name                    = route.key
      address_prefix          = route.value
      next_hop_type           = "VirtualAppliance"
      next_hop_in_ip_address  = var.next_hop_ip
    }
  }
}

# Associate route tables to subnets.

resource "azurerm_subnet_route_table_association" "assocrt" {
  for_each       = {for name, ip in var.subnets: name => ip if name != var.route_table_exclusion}
  subnet_id      = azurerm_subnet.subnets[each.key].id
  route_table_id = azurerm_route_table.default.id
}
