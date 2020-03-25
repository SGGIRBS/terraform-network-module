variable "context_short_name" {
  description = "The context of the network E.G Apps"
}
variable "environment_short_name" {
  description = "Dev, Test, Prod etc"
}
variable "location" {
  default = "West Europe"
  description = "Which region to deploy the resources to"
}
variable "vnet_address_space" {
  description = "The vnet address space"
  default     = "10.220.8.0/21"
}
variable "subnets" {
  type = map
  description = "Define the subnets to create in a map. Key = subnet name and Value = address space"
  default = {
    "ManagementSubnet" = "10.220.8.0/24"
    "WebSubnet" = "10.220.9.0/25"
    "BusinessSubnet" = "10.220.9.128/25"
    "DataSubnet" = "10.220.10.0/25"
  }
}
variable "tags" {
  type = map
  description = "The tags to apply to the resources"
  default = {
    Owner = "John Doe"
    Environment = "Dev"
    CostCentre = "IT"
    ManagedBy = "Terraform"   
  }
}
variable "routes" {
  type = map
  description = "Define the routes to create in a map. Key = route name and Value = address prefix"
  default = {
    "DefaultAF"     = "0.0.0.0/0"
    "HubProdVNET"   = "10.220.0.0/21"
  }
}
variable "next_hop_ip" {
  description = "The ip of the NVA/Azure Firewall for the route(s) next hop"
  default = "10.220.0.4"
}
# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  default     = [
    "10.220.2.4",
    "10.220.2.5",
    "10.220.2.6",
    "10.220.2.7",
    "10.220.2.8",
    "10.220.2.9",
    "10.220.2.10",
    "10.220.2.11",
    "10.201.64.110",
    "168.63.129.16",
  ]
}
variable "route_table_exclusion" {
  description = "Will not add a route table to these subnets"
}
