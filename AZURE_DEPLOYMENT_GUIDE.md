# Azure Deployment Guide

This guide explains how to migrate from AWS to Azure and deploy the LangChain Policy Assistant application to Azure Container Apps.

## Architecture Overview

**AWS → Azure Migration Mapping:**
- **ECR (Elastic Container Registry)** → **ACR (Azure Container Registry)**
- **ECS (Elastic Container Service)** → **Azure Container Apps**
- **AWS CLI** → **Azure CLI**

## Prerequisites

1. **Azure Account** with an active subscription
2. **Azure CLI** installed ([Install Guide](https://aka.ms/installazurecliwindows))
3. **Docker** installed
4. **GitHub Actions** secrets configured

## Step 1: Install Azure CLI

### Windows (PowerShell)
```powershell
# Download and run the MSI installer
# Or use winget
winget install -e --id Microsoft.AzureCLI
```

### Verify Installation
```powershell
az version
az login
```

## Step 2: Create Azure Resources

### 2.1 Login to Azure
```powershell
az login
az account set --subscription <your-subscription-id>
```

### 2.2 Create Resource Group
```powershell
az group create `
  --name policy-assistant-rg `
  --location northeurope
```

### 2.3 Create Azure Container Registry (ACR)
```powershell
az acr create `
  --name policyassistant `
  --resource-group policy-assistant-rg `
  --sku Basic `
  --admin-enabled true
```

**Note:** ACR names must be globally unique, lowercase, and 5-50 alphanumeric characters. Adjust `policyassistant` if needed.

### 2.4 Enable Admin User and Get Credentials
```powershell
az acr credential show --name policyassistant --resource-group policy-assistant-rg
```

Save the username and password - you'll need these for GitHub Secrets.

### 2.5 Create Container Apps Environment
```powershell
az containerapp env create `
  --name policy-assistant-env `
  --resource-group policy-assistant-rg `
  --location northeurope
```

### 2.6 Create Container App
```powershell
az containerapp create `
  --name policy-assistant-app `
  --resource-group policy-assistant-rg `
  --environment policy-assistant-env `
  --image policyassistant.azurecr.io/policy-assistant:latest `
  --registry-server policyassistant.azurecr.io `
  --registry-username <acr-username> `
  --registry-password <acr-password> `
  --target-port 8000 `
  --ingress external `
  --cpu 1.0 `
  --memory 2.0Gi `
  --min-replicas 1 `
  --max-replicas 3 `
  --env-vars "OPENAI_API_KEY=<your-openai-key>" "APP_NAME=LangChain Policy Assistant"
```

## Step 3: Configure GitHub Actions Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions, and add:

### Required Secrets:

1. **AZURE_CREDENTIALS**
   ```powershell
   # Create service principal and get credentials
   az ad sp create-for-rbac --name "policy-assistant-github" `
     --role contributor `
     --scopes /subscriptions/<subscription-id> `
     --sdk-auth
   ```
   Copy the entire JSON output and paste it as the secret value.

2. **ACR_USERNAME**
   - Get from: `az acr credential show --name policyassistant --resource-group policy-assistant-rg`
   - Use the `username` value

3. **ACR_PASSWORD**
   - Get from: `az acr credential show --name policyassistant --resource-group policy-assistant-rg`
   - Use the `passwords[0].value`

4. **OPENAI_API_KEY**
   - Your OpenAI API key for the application

## Step 4: Update Configuration

### Update deploy.yml Environment Variables

Edit `.github/workflows/deploy.yml` and update these values if needed:

```yaml
env:
  AZURE_REGION: northeurope        # Change to your preferred region
  ACR_REGISTRY: policyassistant    # Must match your ACR name
  RESOURCE_GROUP: policy-assistant-rg
  CONTAINER_APP_NAME: policy-assistant-app
  CONTAINER_APP_ENVIRONMENT: policy-assistant-env
```

### Update check_azure_connection.ps1

Update the variables at the top of `check_azure_connection.ps1` to match your Azure resource names.

## Step 5: Test Connection

Run the Azure connection check script:

```powershell
.\check_azure_connection.ps1
```

This will verify:
- Azure CLI installation
- Login status
- Resource group existence
- ACR access
- Container Apps Environment
- Container App status
- ACR login capability

## Step 6: Deploy

Once everything is configured:

1. **Push to main branch** - GitHub Actions will automatically deploy
2. **Or manually deploy:**
   ```powershell
   # Build and push image
   az acr login --name policyassistant
   docker build -t policyassistant.azurecr.io/policy-assistant:latest .
   docker push policyassistant.azurecr.io/policy-assistant:latest
   
   # Update container app
   az containerapp update `
     --name policy-assistant-app `
     --resource-group policy-assistant-rg `
     --image policyassistant.azurecr.io/policy-assistant:latest
   ```

## Step 7: Get Application URL

```powershell
az containerapp show `
  --name policy-assistant-app `
  --resource-group policy-assistant-rg `
  --query properties.configuration.ingress.fqdn `
  --output tsv
```

Visit the URL to access your application!

## Troubleshooting

### Check Container App Logs
```powershell
az containerapp logs show `
  --name policy-assistant-app `
  --resource-group policy-assistant-rg `
  --follow
```

### Check Container App Status
```powershell
az containerapp show `
  --name policy-assistant-app `
  --resource-group policy-assistant-rg `
  --query properties.provisioningState
```

### Common Issues

1. **ACR name already taken**: Choose a different globally unique name
2. **Service principal permissions**: Ensure it has Contributor role on the subscription/resource group
3. **Image pull errors**: Verify ACR credentials in GitHub Secrets
4. **Container crashes**: Check logs and environment variables

## Cost Considerations

- **ACR Basic**: ~$5/month (includes 10GB storage)
- **Container Apps**: Pay per use (CPU/memory consumption)
- **Container Apps Environment**: Free tier available

## Additional Resources

- [Azure Container Apps Documentation](https://docs.microsoft.com/azure/container-apps/)
- [Azure Container Registry Documentation](https://docs.microsoft.com/azure/container-registry/)
- [GitHub Actions for Azure](https://github.com/marketplace?type=actions&query=azure)
