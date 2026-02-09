# AWS to Azure Migration Summary

## Overview
This document summarizes the changes made to migrate the LangChain Policy Assistant application from AWS to Azure.

## Changes Made

### 1. GitHub Actions Workflow (`/.github/workflows/deploy.yml`)
**Before (AWS):**
- Used AWS ECR for container registry
- Used AWS ECS for container orchestration
- Required AWS credentials (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)

**After (Azure):**
- Uses Azure Container Registry (ACR) for container registry
- Uses Azure Container Apps for container orchestration
- Requires Azure credentials (AZURE_CREDENTIALS service principal)

**Key Changes:**
- Replaced AWS authentication with Azure login
- Replaced ECR login with ACR login
- Replaced ECS task definition deployment with Container Apps update
- Added Azure CLI extension installation for Container Apps

### 2. Connection Check Script (`check_azure_connection.ps1`)
**New File:** Created to replace `check_aws_connection.ps1`

**Checks:**
- Azure CLI installation
- Azure login status
- Resource group existence
- Azure Container Registry (ACR) access
- Container Apps Environment status
- Container App status
- ACR login capability

### 3. Documentation (`AZURE_DEPLOYMENT_GUIDE.md`)
**New File:** Comprehensive guide covering:
- Architecture overview (AWS → Azure mapping)
- Prerequisites and installation
- Step-by-step Azure resource creation
- GitHub Actions secrets configuration
- Deployment instructions
- Troubleshooting guide

## Service Mapping

| AWS Service | Azure Equivalent | Purpose |
|------------|------------------|---------|
| ECR (Elastic Container Registry) | ACR (Azure Container Registry) | Container image storage |
| ECS (Elastic Container Service) | Azure Container Apps | Container orchestration |
| AWS CLI | Azure CLI | Command-line interface |
| AWS IAM | Azure AD Service Principal | Authentication & authorization |

## Required GitHub Secrets

**Old (AWS):**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**New (Azure):**
- `AZURE_CREDENTIALS` (Service principal JSON)
- `ACR_USERNAME` (ACR admin username)
- `ACR_PASSWORD` (ACR admin password)
- `OPENAI_API_KEY` (Application secret)

## Configuration Variables

**Old (AWS):**
```yaml
AWS_REGION: eu-north-1
ECR_REPOSITORY: policy-assistant
ECS_CLUSTER: policy-assistant-cluster1
ECS_SERVICE: policy-assistant-task-service-2iz31phw
TASK_DEFINITION_FAMILY: policy-assistant-task
```

**New (Azure):**
```yaml
AZURE_REGION: northeurope
ACR_REGISTRY: policyassistant
RESOURCE_GROUP: policy-assistant-rg
CONTAINER_APP_NAME: policy-assistant-app
CONTAINER_APP_ENVIRONMENT: policy-assistant-env
```

## Application Code
✅ **No changes required** - The application code itself doesn't use AWS SDK, so no code changes are needed.

## Next Steps

1. **Set up Azure resources** following `AZURE_DEPLOYMENT_GUIDE.md`
2. **Configure GitHub Secrets** as outlined in the deployment guide
3. **Update configuration variables** in `deploy.yml` if needed (especially ACR_REGISTRY name)
4. **Test connection** using `check_azure_connection.ps1`
5. **Deploy** by pushing to main branch or manually

## Files Modified/Created

### Modified:
- `.github/workflows/deploy.yml` - Complete rewrite for Azure

### Created:
- `check_azure_connection.ps1` - Azure connection verification script
- `AZURE_DEPLOYMENT_GUIDE.md` - Comprehensive deployment guide
- `MIGRATION_SUMMARY.md` - This file

### Unchanged:
- Application code (`app/` directory)
- `Dockerfile`
- `requirements.txt`
- `test_api.ps1`

## Notes

- The old AWS connection check script (`check_aws_connection.ps1`) is still present but can be removed if no longer needed
- ACR names must be globally unique, lowercase, and 5-50 alphanumeric characters
- Azure Container Apps provides automatic scaling, HTTPS, and integrated logging
- The deployment workflow now outputs the application URL after successful deployment
