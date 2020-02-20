# Azure network configuration. NSG rules are not yet included.

# resource for reference

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
  address_space       = ["${var.vnet_address_space}"]
  dns_servers         = var.dns_servers
  tags = var.tags
}

# Create NSGs (based on subnets)

resource "azurerm_network_security_group" "nsgs" {
  for_each            = var.subnets
  name                = "${var.context_short_name}-${each.key}-NSG"
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
  network_security_group_id = azurerm_network_security_group.nsgs[each.key].id
  route_table_id       = each.key != var.route_table_exclusion ? azurerm_route_table.default.id: ""
  service_endpoints    = each.key != var.route_table_exclusion ? [] : ["Microsoft.Sql"]
}


# Associated NSGs to Subnets

resource "azurerm_subnet_network_security_group_association" "assocnsg" {
  for_each                  = var.subnets
  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsgs[each.key].id
}

# Create Route Tables.

resource "azurerm_route_table" "default" {
  name                          = "Default-RT"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

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
