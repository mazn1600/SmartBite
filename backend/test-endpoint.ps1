# Test script to verify POST endpoint works
Write-Host "Testing POST endpoint..."
Write-Host ""

$body = @{
    dishName = "Grilled Chicken"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/food-analysis/full-pipeline" `
        -Method POST `
        -Headers @{"Content-Type"="application/json"} `
        -Body $body `
        -ErrorAction Stop
    
    Write-Host "✅ SUCCESS!" -ForegroundColor Green
    Write-Host "Status Code: $($response.StatusCode)"
    Write-Host "Response:"
    Write-Host $response.Content
} catch {
    Write-Host "❌ ERROR!" -ForegroundColor Red
    Write-Host $_.Exception.Message
    Write-Host ""
    Write-Host "Make sure:"
    Write-Host "1. Backend server is running: cd backend && npm run start:dev"
    Write-Host "2. Server is accessible: http://localhost:3000/api/docs"
}

