# Test script for LangChain Policy Assistant API
# Usage: .\test_api.ps1

$uri = "http://127.0.0.1:8000/ask"

# Test data
$body = @{
    question = "How many casual leaves?"
    prompt_version = "v2"
    top_k = 5
} | ConvertTo-Json

Write-Host "Testing API endpoint: $uri" -ForegroundColor Cyan
Write-Host "Request body:" -ForegroundColor Yellow
Write-Host $body -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $uri -Method POST -Body $body -ContentType "application/json"
    
    Write-Host "✅ Success!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

