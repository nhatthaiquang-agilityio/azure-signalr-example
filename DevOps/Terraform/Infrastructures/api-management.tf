resource "azurerm_api_management" "az_api_mng_svc" {
  name                = "${var.environment}-az-api-svc"
  location            = data.azurerm_resource_group.rg_signalr.location
  resource_group_name = data.azurerm_resource_group.rg_signalr.name
  publisher_name      = "Example Publisher"
  publisher_email     = "nhat.thaiquang@asnet.com.vn"
  sku_name            = "Standard_2"
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
