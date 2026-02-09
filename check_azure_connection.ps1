# Azure Connection Check Script
# This script verifies Azure connectivity and deployment status

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure Connection Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration from deploy.yml
$AZURE_REGION = "northeurope"
$ACR_REGISTRY = "policyassistant"
$RESOURCE_GROUP = "policy-assistant-rg"
$CONTAINER_APP_NAME = "policy-assistant-app"
$CONTAINER_APP_ENVIRONMENT = "policy-assistant-env"

# Check 1: Azure CLI Installation
Write-Host "1. Checking Azure CLI installation..." -ForegroundColor Yellow
try {
    $azVersion = az version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $versionInfo = az version --output json | ConvertFrom-Json
        Write-Host "   [OK] Azure CLI installed: $($versionInfo.'azure-cli')" -ForegroundColor Green
    } else {
        Write-Host "   [ERROR] Azure CLI not found. Install from: https://aka.ms/installazurecliwindows" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   [ERROR] Azure CLI not found. Install from: https://aka.ms/installazurecliwindows" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Check 2: Azure Login Status
Write-Host "2. Checking Azure login status..." -ForegroundColor Yellow
try {
    $account = az account show 2>&1
    if ($LASTEXITCODE -eq 0) {
        $accountInfo = $account | ConvertFrom-Json
        Write-Host "   [OK] Azure account logged in" -ForegroundColor Green
        Write-Host "   Subscription: $($accountInfo.name)" -ForegroundColor Gray
        Write-Host "   Subscription ID: $($accountInfo.id)" -ForegroundColor Gray
        Write-Host "   Tenant ID: $($accountInfo.tenantId)" -ForegroundColor Gray
    } else {
        Write-Host "   [ERROR] Not logged in to Azure. Run: az login" -ForegroundColor Red
        Write-Host "   Then set subscription: az account set --subscription <subscription-id>" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   [ERROR] Failed to check Azure login: $_" -ForegroundColor Red
}
Write-Host ""

# Check 3: Resource Group
Write-Host "3. Checking resource group..." -ForegroundColor Yellow
try {
    $rg = az group show --name $RESOURCE_GROUP 2>&1
    if ($LASTEXITCODE -eq 0) {
        $rgInfo = $rg | ConvertFrom-Json
        Write-Host "   [OK] Resource group '$RESOURCE_GROUP' exists" -ForegroundColor Green
        Write-Host "   Location: $($rgInfo.location)" -ForegroundColor Gray
    } else {
        Write-Host "   [WARNING] Resource group '$RESOURCE_GROUP' not found" -ForegroundColor Yellow
        Write-Host "   Create it with: az group create --name $RESOURCE_GROUP --location $AZURE_REGION" -ForegroundColor Gray
    }
} catch {
    Write-Host "   [ERROR] Failed to check resource group: $_" -ForegroundColor Red
}
Write-Host ""

# Check 4: Azure Container Registry (ACR)
Write-Host "4. Checking Azure Container Registry..." -ForegroundColor Yellow
try {
    $acr = az acr show --name $ACR_REGISTRY --resource-group $RESOURCE_GROUP 2>&1
    if ($LASTEXITCODE -eq 0) {
        $acrInfo = $acr | ConvertFrom-Json
        Write-Host "   [OK] ACR '$ACR_REGISTRY' exists" -ForegroundColor Green
        Write-Host "   Login server: $($acrInfo.loginServer)" -ForegroundColor Gray
        Write-Host "   SKU: $($acrInfo.sku.name)" -ForegroundColor Gray
        Write-Host "   Status: $($acrInfo.provisioningState)" -ForegroundColor Gray
    } else {
        Write-Host "   [WARNING] ACR '$ACR_REGISTRY' not found" -ForegroundColor Yellow
        Write-Host "   Create it with: az acr create --name $ACR_REGISTRY --resource-group $RESOURCE_GROUP --sku Basic" -ForegroundColor Gray
    }
} catch {
    Write-Host "   [ERROR] Failed to check ACR: $_" -ForegroundColor Red
}
Write-Host ""

# Check 5: Container Apps Environment
Write-Host "5. Checking Container Apps Environment..." -ForegroundColor Yellow
try {
    $env = az containerapp env show --name $CONTAINER_APP_ENVIRONMENT --resource-group $RESOURCE_GROUP 2>&1
    if ($LASTEXITCODE -eq 0) {
        $envInfo = $env | ConvertFrom-Json
        Write-Host "   [OK] Container Apps Environment '$CONTAINER_APP_ENVIRONMENT' exists" -ForegroundColor Green
        Write-Host "   Location: $($envInfo.location)" -ForegroundColor Gray
        Write-Host "   Provisioning State: $($envInfo.provisioningState)" -ForegroundColor Gray
    } else {
        Write-Host "   [WARNING] Container Apps Environment '$CONTAINER_APP_ENVIRONMENT' not found" -ForegroundColor Yellow
        Write-Host "   Create it with: az containerapp env create --name $CONTAINER_APP_ENVIRONMENT --resource-group $RESOURCE_GROUP --location $AZURE_REGION" -ForegroundColor Gray
    }
} catch {
    Write-Host "   [ERROR] Failed to check Container Apps Environment: $_" -ForegroundColor Red
}
Write-Host ""

# Check 6: Container App
Write-Host "6. Checking Container App..." -ForegroundColor Yellow
try {
    $app = az containerapp show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP 2>&1
    if ($LASTEXITCODE -eq 0) {
        $appInfo = $app | ConvertFrom-Json
        Write-Host "   [OK] Container App '$CONTAINER_APP_NAME' exists" -ForegroundColor Green
        Write-Host "   Status: $($appInfo.properties.provisioningState)" -ForegroundColor Gray
        Write-Host "   Running Replicas: $($appInfo.properties.runningStatus)" -ForegroundColor Gray
        
        if ($appInfo.properties.configuration.ingress) {
            Write-Host "   Ingress: Enabled" -ForegroundColor Gray
            Write-Host "   FQDN: $($appInfo.properties.configuration.ingress.fqdn)" -ForegroundColor Gray
        }
    } else {
        Write-Host "   [WARNING] Container App '$CONTAINER_APP_NAME' not found" -ForegroundColor Yellow
        Write-Host "   Create it after setting up ACR and Container Apps Environment" -ForegroundColor Gray
    }
} catch {
    Write-Host "   [ERROR] Failed to check Container App: $_" -ForegroundColor Red
}
Write-Host ""

# Check 7: Test ACR Login
Write-Host "7. Testing ACR login..." -ForegroundColor Yellow
try {
    $loginResult = az acr login --name $ACR_REGISTRY 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] ACR login successful" -ForegroundColor Green
    } else {
        Write-Host "   [ERROR] ACR login failed" -ForegroundColor Red
    }
} catch {
    Write-Host "   [ERROR] Failed to test ACR login: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Check Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. If not logged in: az login" -ForegroundColor Gray
Write-Host "2. Set subscription: az account set --subscription <subscription-id>" -ForegroundColor Gray
Write-Host "3. Check GitHub Actions secrets are set:" -ForegroundColor Gray
Write-Host "   - AZURE_CREDENTIALS (service principal JSON)" -ForegroundColor Gray
Write-Host "   - ACR_USERNAME (ACR admin username)" -ForegroundColor Gray
Write-Host "   - ACR_PASSWORD (ACR admin password)" -ForegroundColor Gray
Write-Host "   - OPENAI_API_KEY (for your application)" -ForegroundColor Gray
Write-Host "4. Verify deployment: Check GitHub Actions workflow runs" -ForegroundColor Gray
Write-Host ""
Write-Host "To create AZURE_CREDENTIALS secret:" -ForegroundColor Yellow
Write-Host "  az ad sp create-for-rbac --name 'policy-assistant-github' --role contributor --scopes /subscriptions/<subscription-id> --sdk-auth" -ForegroundColor Gray
