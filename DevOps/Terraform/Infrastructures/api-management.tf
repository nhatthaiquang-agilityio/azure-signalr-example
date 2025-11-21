resource "azurerm_api_management" "az_api_mng_svc" {
  name                = "${var.environment}-az-api-svc-mng"
  location            = data.azurerm_resource_group.rg_signalr.location
  resource_group_name = data.azurerm_resource_group.rg_signalr.name
  publisher_name      = "Example Publisher"
  publisher_email     = "nhat.thaiquang@asnet.com.vn"
  sku_name            = "Premium_1"

  # Enable virtual network integration
  virtual_network_type = "Internal"
  virtual_network_configuration {
    subnet_id = azurerm_subnet.az_apim_subnet.id
  }

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_api_management_api" "api" {
  name                = "${var.environment}-api"
  resource_group_name = data.azurerm_resource_group.rg_signalr.name
  api_management_name = azurerm_api_management.az_api_mng_svc.name
  revision            = "1"
  display_name        = "${var.environment}-api"
  path                = "example"
  protocols           = ["https", "http"]
  description         = "An example API"

  subscription_key_parameter_names  {
    header = "Ocp-Apim-Subscription-Key"
    query = "access-key"
  }
}


resource "azurerm_api_management_product" "product" {
  product_id            = "${var.environment}-product"
  resource_group_name   = data.azurerm_resource_group.rg_signalr.name
  api_management_name   = azurerm_api_management.az_api_mng_svc.name
  display_name          = "${var.environment}-product"
  subscription_required = true
  approval_required     = false
  published             = true
  description           = "An example Product"
}

resource "azurerm_api_management_group" "group" {
  name                = "${var.environment}-group"
  resource_group_name = data.azurerm_resource_group.rg_signalr.name
  api_management_name = azurerm_api_management.az_api_mng_svc.name
  display_name        = "${var.environment}-group"
  description         = "An example group"
}

resource "azurerm_api_management_product_api" "product_api" {
  resource_group_name = data.azurerm_resource_group.rg_signalr.name
  api_management_name = azurerm_api_management.az_api_mng_svc.name
  product_id          = azurerm_api_management_product.product.product_id
  api_name            = azurerm_api_management_api.api.name
}

resource "azurerm_api_management_product_group" "product_group" {
  resource_group_name = data.azurerm_resource_group.rg_signalr.name
  api_management_name = azurerm_api_management.az_api_mng_svc.name
  product_id          = azurerm_api_management_product.product.product_id
  group_name          = azurerm_api_management_group.group.name
}

# SignalR Backend Configuration
resource "azurerm_api_management_backend" "signalr_backend" {
  name                = "signalr-backend"
  resource_group_name = data.azurerm_resource_group.rg_signalr.name
  api_management_name = azurerm_api_management.az_api_mng_svc.name
  protocol            = "http"
  url                 = "https://${azurerm_signalr_service.signalr_example.hostname}"
  description         = "SignalR Service Backend"

  # Use private endpoint IP
  tls {
    validate_certificate_chain = true
    validate_certificate_name  = true
  }
}

# Store SignalR connection string as named value
resource "azurerm_api_management_named_value" "signalr_connection_string" {
  name                = "SignalRConnectionString"
  resource_group_name = data.azurerm_resource_group.rg_signalr.name
  api_management_name = azurerm_api_management.az_api_mng_svc.name
  display_name        = "SignalRConnectionString"
  value               = azurerm_signalr_service.signalr_example.primary_connection_string
  secret              = true
}

# Store SignalR access key
resource "azurerm_api_management_named_value" "signalr_access_key" {
  name                = "SignalRAccessKey"
  resource_group_name = data.azurerm_resource_group.rg_signalr.name
  api_management_name = azurerm_api_management.az_api_mng_svc.name
  display_name        = "SignalRAccessKey"
  value               = azurerm_signalr_service.signalr_example.primary_access_key
  secret              = true
}

# API Management operation for SignalR negotiate
resource "azurerm_api_management_api_operation" "signalr_negotiate" {
  operation_id        = "signalr-negotiate"
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.az_api_mng_svc.name
  resource_group_name = data.azurerm_resource_group.rg_signalr.name
  display_name        = "SignalR Negotiate"
  method              = "POST"
  url_template        = "/negotiate"
  description         = "SignalR negotiation endpoint"

  response {
    status_code = 200
    description = "Successful negotiation"
  }
}

# Policy for SignalR negotiate operation
resource "azurerm_api_management_api_operation_policy" "signalr_negotiate_policy" {
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.az_api_mng_svc.name
  resource_group_name = data.azurerm_resource_group.rg_signalr.name
  operation_id        = azurerm_api_management_api_operation.signalr_negotiate.operation_id

  xml_content = <<XML
<policies>
    <inbound>
        <base />
        <set-backend-service backend-id="signalr-backend" />
        <rewrite-uri template="/client/negotiate" />
        <set-header name="Authorization" exists-action="override">
            <value>Bearer {{SignalRAccessKey}}</value>
        </set-header>
        <set-header name="Content-Type" exists-action="override">
            <value>application/json</value>
        </set-header>
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
XML
}
