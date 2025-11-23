# Build script that automatically fixes Firebase CMake issues
# This script handles the SDK extraction and patching workflow

param(
    [string]$BuildType = "debug"
)

$ErrorActionPreference = "Continue"

Write-Host "=== LifeMate Windows Build Script ===" -ForegroundColor Cyan
Write-Host ""

# Get the project root directory
$projectRoot = Split-Path -Parent $PSScriptRoot

# Change to project root
Set-Location $projectRoot

Write-Host "Step 1: Running flutter pub get..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to get dependencies" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 2: Checking for Firebase SDK..." -ForegroundColor Yellow
$firebaseSdkPath = "$projectRoot\build\windows\x64\extracted\firebase_cpp_sdk_windows\CMakeLists.txt"

# If SDK doesn't exist, try to extract it first by running a build
if (-not (Test-Path $firebaseSdkPath)) {
    Write-Host "Firebase SDK not found. Attempting to extract it..." -ForegroundColor Yellow
    Write-Host "This may fail on first attempt, which is normal." -ForegroundColor Yellow
    
    # Run flutter build to extract SDK (this will fail but SDK will be extracted)
    flutter build windows --debug 2>&1 | Out-Null
}

# Now patch the SDK if it exists
Write-Host ""
Write-Host "Step 3: Running Firebase CMake fix script..." -ForegroundColor Yellow
& "$PSScriptRoot\fix_firebase_cmake.ps1"

Write-Host ""
Write-Host "Step 4: Building Flutter app for Windows ($BuildType)..." -ForegroundColor Yellow
if ($BuildType -eq "debug") {
    flutter run -d windows
} else {
    flutter build windows --$BuildType
}

