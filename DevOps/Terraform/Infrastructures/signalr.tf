# SignalR Service
resource "azurerm_signalr_service" "signalr_example" {
  name                = var.signalr_name
  location            = data.azurerm_resource_group.rg_signalr.location
  resource_group_name = data.azurerm_resource_group.rg_signalr.name

	tags     			  			= merge(var.tags, {
    environment = var.environment
  })

  sku {
    name     = "Standard_S1"
    capacity = 1
  }

  cors {
    allowed_origins = var.allowed_origins
  }

  public_network_access_enabled = var.public_network_access_enabled

  connectivity_logs_enabled = true
  messaging_logs_enabled    = true
  http_request_logs_enabled = true
  service_mode              = "Default"
}


# Private Endpoint
resource "azurerm_private_endpoint" "pv_endpoint_signalr" {
  name                = var.pv_endpoint_name
  resource_group_name = data.azurerm_resource_group.rg_signalr.name
  location            = data.azurerm_resource_group.rg_signalr.location
  subnet_id           = azurerm_subnet.az_signalr_subnet_pe.id

	tags     			  			= merge(var.tags, {
    environment = var.environment
  })

custom_network_interface_name = var.network_interface_signalr

  private_service_connection {
    name                           = var.pv_svc_connection_signalr
    is_manual_connection           = false
    private_connection_resource_id = azurerm_signalr_service.signalr_example.id
    subresource_names              = ["signalr"]
  }

# Set static IP
  ip_configuration {
    name                          = "pv-endpoint-ip-config"
    private_ip_address            = var.pv_endpoint_static_ip
    subresource_name              = "signalr"
    member_name                   = "signalr"
  }
}