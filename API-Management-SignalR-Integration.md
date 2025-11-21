# API Management to Azure SignalR Private Endpoint Configuration Guide

## Overview
This guide explains how to configure Azure API Management to connect to Azure SignalR through a private endpoint, ensuring secure communication within your virtual network.

## Architecture Components

### 1. Network Configuration
- **VNet**: `az-signalr-vn-vnet` (10.0.0.0/16)
- **Subnets**:
  - Internal subnet: `subnet-int-az-signalr` (10.0.1.0/24) - for app services
  - Private endpoint subnet: `subnet-pe-az-signalr` (10.0.2.0/24) - for SignalR PE
  - API Management subnet: `subnet-apim-az-signalr` (10.0.3.0/24) - for APIM

### 2. SignalR Configuration
- **Service**: `signalr-test-example`
- **SKU**: Standard_S1
- **Public Access**: Disabled
- **Private Endpoint**: `pe-signalr-test-example` with static IP `10.0.2.11`

### 3. API Management Configuration
- **SKU**: Standard_2 (required for VNet integration)
- **Network Type**: Internal (deployed within VNet)
- **Subnet**: `subnet-apim-az-signalr`

## Configuration Steps

### Step 1: Deploy the Updated Infrastructure

```bash
# Navigate to terraform directory
cd DevOps/Terraform/Infrastructures

# Initialize terraform
terraform init

# Plan deployment
terraform plan -var-file="Environments/test.tfvars"

# Apply changes
terraform apply -var-file="Environments/test.tfvars"
```

### Step 2: Verify Network Connectivity

After deployment, verify that API Management can resolve and connect to SignalR:

```bash
# Check private endpoint DNS resolution
nslookup signalr-test-example.service.signalr.net

# Should resolve to the private IP: 10.0.2.11
```

### Step 3: Test SignalR Integration

1. **Access API Management Developer Portal**
2. **Test the `/negotiate` endpoint**
3. **Verify SignalR connection establishment**

## Key Configuration Elements

### 1. Virtual Network Integration
```terraform
virtual_network_type = "Internal"
virtual_network_configuration {
  subnet_id = azurerm_subnet.az_apim_subnet.id
}
```

### 2. SignalR Backend Configuration
```terraform
resource "azurerm_api_management_backend" "signalr_backend" {
  protocol = "http"
  url      = "https://${azurerm_signalr_service.signalr_example.hostname}"
}
```

### 3. Private DNS Zone
```terraform
resource "azurerm_private_dns_zone" "signalr_dns" {
  name = "privatelink.service.signalr.net"
}
```

### 4. API Policy for SignalR Negotiate
```xml
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
</policies>
```

## API Usage Examples

### 1. SignalR Negotiate Request
```bash
POST /example/negotiate
Host: {api-management-gateway}
Ocp-Apim-Subscription-Key: {subscription-key}
Content-Type: application/json
```

### 2. Client Connection
```javascript
const connection = new signalR.HubConnectionBuilder()
    .withUrl("https://{api-management-gateway}/example/negotiate")
    .build();

connection.start().then(() => {
    console.log("Connected to SignalR via API Management");
});
```

## Security Considerations

1. **Network Isolation**: SignalR is only accessible through private endpoint
2. **Access Control**: API Management enforces subscription key authentication
3. **SSL/TLS**: All communication encrypted in transit
4. **Private DNS**: Custom DNS zone ensures proper name resolution

## Monitoring and Troubleshooting

### 1. Check API Management Network Status
```bash
# Verify APIM network configuration
az network nic show --resource-group rg-signal-example --name {apim-nic-name}
```

### 2. Verify Private Endpoint Connectivity
```bash
# Check private endpoint status
az network private-endpoint show --resource-group rg-signal-example --name pe-signalr-test-example
```

### 3. Test DNS Resolution
```bash
# From within the VNet, test DNS resolution
nslookup signalr-test-example.service.signalr.net
```

### 4. Monitor API Management Logs
- Enable API Management diagnostic settings
- Monitor backend connectivity issues
- Check policy execution logs

## Best Practices

1. **Use Standard SKU or higher** for API Management to enable VNet integration
2. **Implement proper error handling** in policies for backend failures
3. **Monitor performance** and adjust capacity as needed
4. **Regular security audits** of network access and policies
5. **Backup configuration** before making changes

## Common Issues and Solutions

### Issue: API Management cannot connect to SignalR
**Solution**: Verify that:
- API Management is deployed in the same VNet
- Private DNS zone is properly configured
- NSG rules allow traffic between subnets

### Issue: DNS resolution fails
**Solution**:
- Check private DNS zone configuration
- Verify VNet link is active
- Ensure private endpoint DNS zone group is configured

### Issue: Authentication failures
**Solution**:
- Verify SignalR access key is correctly stored as named value
- Check API policy header configuration
- Validate SignalR service permissions

## Additional Resources

- [Azure API Management VNet Integration](https://docs.microsoft.com/en-us/azure/api-management/api-management-using-with-vnet)
- [Azure SignalR Private Endpoints](https://docs.microsoft.com/en-us/azure/azure-signalr/howto-private-endpoints)
- [API Management Policies](https://docs.microsoft.com/en-us/azure/api-management/api-management-policies)