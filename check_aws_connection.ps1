# AWS Connection Check Script
# This script verifies AWS connectivity and deployment status

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AWS Connection Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration from deploy.yml
$AWS_REGION = "eu-north-1"
$ECR_REPOSITORY = "policy-assistant"
$ECS_CLUSTER = "policy-assistant-cluster1"
$ECS_SERVICE = "policy-assistant-task-service-2iz31phw"
$TASK_DEFINITION_FAMILY = "policy-assistant-task"

# Check 1: AWS CLI Installation
Write-Host "1. Checking AWS CLI installation..." -ForegroundColor Yellow
try {
    $awsVersion = aws --version 2>&1
    Write-Host "   [OK] AWS CLI installed: $awsVersion" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] AWS CLI not found. Install from: https://aws.amazon.com/cli/" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Check 2: AWS Credentials Configuration
Write-Host "2. Checking AWS credentials..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] AWS credentials configured" -ForegroundColor Green
        $identity | ConvertFrom-Json | ForEach-Object {
            Write-Host "   Account: $($_.Account)" -ForegroundColor Gray
            Write-Host "   User/Role: $($_.Arn)" -ForegroundColor Gray
        }
    } else {
        Write-Host "   [ERROR] AWS credentials not configured or invalid" -ForegroundColor Red
        Write-Host "   Run: aws configure" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   [ERROR] Failed to verify AWS credentials: $_" -ForegroundColor Red
}
Write-Host ""

# Check 3: ECR Repository Access
Write-Host "3. Checking ECR repository access..." -ForegroundColor Yellow
try {
    $ecrRepos = aws ecr describe-repositories --region $AWS_REGION --repository-names $ECR_REPOSITORY 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] ECR repository '$ECR_REPOSITORY' exists" -ForegroundColor Green
        $repo = $ecrRepos | ConvertFrom-Json
        Write-Host "   Repository URI: $($repo.repositories[0].repositoryUri)" -ForegroundColor Gray
    } else {
        Write-Host "   [WARNING] ECR repository '$ECR_REPOSITORY' not found or no access" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   [ERROR] Failed to check ECR: $_" -ForegroundColor Red
}
Write-Host ""

# Check 4: ECS Cluster Status
Write-Host "4. Checking ECS cluster status..." -ForegroundColor Yellow
try {
    $cluster = aws ecs describe-clusters --clusters $ECS_CLUSTER --region $AWS_REGION 2>&1
    if ($LASTEXITCODE -eq 0) {
        $clusterData = $cluster | ConvertFrom-Json
        if ($clusterData.clusters.Count -gt 0) {
            Write-Host "   [OK] ECS cluster '$ECS_CLUSTER' exists" -ForegroundColor Green
            Write-Host "   Status: $($clusterData.clusters[0].status)" -ForegroundColor Gray
            Write-Host "   Running tasks: $($clusterData.clusters[0].runningTasksCount)" -ForegroundColor Gray
            Write-Host "   Pending tasks: $($clusterData.clusters[0].pendingTasksCount)" -ForegroundColor Gray
        } else {
            Write-Host "   [WARNING] Cluster '$ECS_CLUSTER' not found" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   [WARNING] Failed to access cluster '$ECS_CLUSTER'" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   [ERROR] Failed to check ECS cluster: $_" -ForegroundColor Red
}
Write-Host ""

# Check 5: ECS Service Status
Write-Host "5. Checking ECS service status..." -ForegroundColor Yellow
try {
    $service = aws ecs describe-services --cluster $ECS_CLUSTER --services $ECS_SERVICE --region $AWS_REGION 2>&1
    if ($LASTEXITCODE -eq 0) {
        $serviceData = $service | ConvertFrom-Json
        if ($serviceData.services.Count -gt 0) {
            $svc = $serviceData.services[0]
            Write-Host "   [OK] ECS service '$ECS_SERVICE' exists" -ForegroundColor Green
            Write-Host "   Status: $($svc.status)" -ForegroundColor Gray
            Write-Host "   Running count: $($svc.runningCount)" -ForegroundColor Gray
            Write-Host "   Desired count: $($svc.desiredCount)" -ForegroundColor Gray
            
            if ($svc.loadBalancers.Count -gt 0) {
                Write-Host "   Load Balancer:" -ForegroundColor Gray
                $svc.loadBalancers | ForEach-Object {
                    Write-Host "     - $($_.targetGroupArn)" -ForegroundColor Gray
                }
            }
        } else {
            Write-Host "   [WARNING] Service '$ECS_SERVICE' not found" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   [WARNING] Failed to access service '$ECS_SERVICE'" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   [ERROR] Failed to check ECS service: $_" -ForegroundColor Red
}
Write-Host ""

# Check 6: Task Definition
Write-Host "6. Checking task definition..." -ForegroundColor Yellow
try {
    $taskDef = aws ecs describe-task-definition --task-definition $TASK_DEFINITION_FAMILY --region $AWS_REGION 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] Task definition '$TASK_DEFINITION_FAMILY' exists" -ForegroundColor Green
        $taskData = $taskDef | ConvertFrom-Json
        Write-Host "   Revision: $($taskData.taskDefinition.revision)" -ForegroundColor Gray
        Write-Host "   Status: $($taskData.taskDefinition.status)" -ForegroundColor Gray
    } else {
        Write-Host "   [WARNING] Task definition '$TASK_DEFINITION_FAMILY' not found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   [ERROR] Failed to check task definition: $_" -ForegroundColor Red
}
Write-Host ""

# Check 7: Test ECR Login
Write-Host "7. Testing ECR login..." -ForegroundColor Yellow
try {
    $ecrLogin = aws ecr get-login-password --region $AWS_REGION 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] ECR login successful" -ForegroundColor Green
    } else {
        Write-Host "   [ERROR] ECR login failed" -ForegroundColor Red
    }
} catch {
    Write-Host "   [ERROR] Failed to test ECR login: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Check Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. If credentials are missing: aws configure" -ForegroundColor Gray
Write-Host "2. Check GitHub Actions secrets are set:" -ForegroundColor Gray
Write-Host "   - AWS_ACCESS_KEY_ID" -ForegroundColor Gray
Write-Host "   - AWS_SECRET_ACCESS_KEY" -ForegroundColor Gray
Write-Host "3. Verify deployment: Check GitHub Actions workflow runs" -ForegroundColor Gray
