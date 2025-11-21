resource "azurerm_network_security_group" "az_signalr_network_sg" {
  name                = "example-security-group"
  location            = data.azurerm_resource_group.rg_signalr.location
  resource_group_name = data.azurerm_resource_group.rg_signalr.name
}

# Virtual Network
resource "azurerm_virtual_network" "az_signalr_network" {
  name                = "az-signalr-vn-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg_signalr.location
  resource_group_name = data.azurerm_resource_group.rg_signalr.name
}

# Subnet 1: internal
resource "azurerm_subnet" "az_signalr_subnet_int" {
  name                 = "subnet-int-az-signalr"
  resource_group_name  = data.azurerm_resource_group.rg_signalr.name
  virtual_network_name = azurerm_virtual_network.az_signalr_network.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "example-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
  service_endpoints = [
    "Microsoft.EventHub",
    "Microsoft.KeyVault",
    "Microsoft.ServiceBus",
    "Microsoft.Storage",
    "Microsoft.Web"
  ]
}

# Subnet 2: private Endpoint
resource "azurerm_subnet" "az_signalr_subnet_pe" {
  name                 = "subnet-pe-az-signalr"
  resource_group_name  = data.azurerm_resource_group.rg_signalr.name
  virtual_network_name = azurerm_virtual_network.az_signalr_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Subnet 3: API Management
resource "azurerm_subnet" "az_apim_subnet" {
  name                 = "subnet-apim-az-signalr"
  resource_group_name  = data.azurerm_resource_group.rg_signalr.name
  virtual_network_name = azurerm_virtual_network.az_signalr_network.name
  address_prefixes     = ["10.0.3.0/24"]
  network_security_group_id = azurerm_network_security_group.az_signalr_network_sg.id

  # Required service endpoints for API Management
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.EventHub",
    "Microsoft.ServiceBus"
  ]
}
