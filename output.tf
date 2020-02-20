# Output subnet Ids

output "subnets" {
  value = azurerm_subnet.subnets
}

# Output vnet Ids

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

# Output NSGS

output "nsgs" {
  value = azurerm_network_security_group.nsgs
}

# Output RG name

output "rg_name" {
  value = azurerm_resource_group.rg.name
}
