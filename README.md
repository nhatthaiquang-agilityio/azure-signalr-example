# Azure SignalR Private Endpoint
    + Create Infrastructure with Terraform
    + Deploy the Azure Signalr(Private Endpoint) with GitHub Actions

### Features
    + An Azure Virtual Network and Private Endpoint
    + PrivateLink DNZ
    + Deployment with GitHub Actions

## Prerequisites
### Create client id and client secret with Contributor Role for deployment
    + Create client id, client secret, subscription and tenant id
    ```
    az ad sp create-for-rbac --name "github-deployment" --role contributor --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP> --sdk-auth
    ```

    + Add AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_SUBSCRIPTION_ID and AZURE_TENANT_ID into Secret of GitHub Repo(Using Terraform)

    + Add AZURE_CREDENTIALS into Secret of GitHub Repo (using Azure Login)
    ```
    {
        "clientSecret": "",
        "subscriptionId": "",
        "tenantId": "",
        "clientId": ""
    }
    ```

### Create Storage Account in Azure Portal
    + Create a storage account and a container. It will be save terraform state file.
![Terraform State File](./Images/terraform-state-file.png)

### Create GitHub Agent(Self-hosted Runner)
    + Create Azure Virtual Machine(the same virtual network of Azure Function App)
        - Install Azure CLI
        - Install self-hosted runner

![Install Self Hosted Runner](./Images/gh-agent-deployment.png)