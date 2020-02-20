variable "context_short_name" {}
variable "environment_short_name" {}
variable "location" {
    default = "West Europe"
}

variable "vnet_address_space" {}
variable "subnets" {
  type = map
  description = "Define the subnets to create in a map. Key = subnet name and Value = address space"
}

variable "tags" {
    type = map
}

variable "routes" {
  type = map
  default = {
    "Internet"      = "0.0.0.0/0"
    "AppsDevManSubnet"  = "10.220.8.0/24"
    "AppsProdManSubnet" = "10.220.16.0/24"
  }
}

variable "next_hop_ip" {
  default = "10.220.0.4"
}

# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  default     = [
    "10.220.2.4",
    "10.220.2.5",
  ]
}

variable "route_table_exclusion" {
  description = "will not add a route table to these subnets"
  default = "ERPSSISIRSubnet"
}
