# Blazecoin V1.5 - Change Verification Script
# This script verifies that all code modifications were applied correctly

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Blazecoin V1.5 - Change Verification" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$baseDir = "C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\src"
$allPassed = $true

# Test 1: Check clientversion.h
Write-Host "[1/4] Checking clientversion.h..." -ForegroundColor Yellow
$versionFile = Get-Content "$baseDir\clientversion.h" -Raw
if ($versionFile -match "CLIENT_VERSION_MAJOR\s+1" -and 
    $versionFile -match "CLIENT_VERSION_MINOR\s+5" -and
    $versionFile -match "CLIENT_VERSION_REVISION\s+0" -and
    $versionFile -match "CLIENT_VERSION_BUILD\s+0" -and
    $versionFile -match "COPYRIGHT_YEAR\s+2026") {
    Write-Host "  ✅ Version 1.5.0.0 confirmed" -ForegroundColor Green
    Write-Host "  ✅ Copyright year 2026 confirmed" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAILED: Version or copyright not updated correctly" -ForegroundColor Red
    $allPassed = $false
}
Write-Host ""

# Test 2: Check main.cpp line 3603
Write-Host "[2/4] Checking main.cpp (getheaders limit)..." -ForegroundColor Yellow
$mainFile = Get-Content "$baseDir\main.cpp"
$line3603 = $mainFile[3602]  # Zero-indexed
if ($line3603 -match "50000000" -and $line3603 -match "V1\.5") {
    Write-Host "  ✅ Line 3603: getheaders limit = 50,000,000" -ForegroundColor Green
    Write-Host "  ✅ V1.5 comment present" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAILED: Line 3603 not updated correctly" -ForegroundColor Red
    Write-Host "  Current line: $line3603" -ForegroundColor Red
    $allPassed = $false
}
Write-Host ""

# Test 3: Check main.cpp line 2281
Write-Host "[3/4] Checking main.cpp (inventory relay limit)..." -ForegroundColor Yellow
$line2281 = $mainFile[2280]  # Zero-indexed
if ($line2281 -match "50000000" -and $line2281 -match "V1\.5") {
    Write-Host "  ✅ Line 2281: inventory relay limit = 50,000,000" -ForegroundColor Green
    Write-Host "  ✅ V1.5 comment present" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAILED: Line 2281 not updated correctly" -ForegroundColor Red
    Write-Host "  Current line: $line2281" -ForegroundColor Red
    $allPassed = $false
}
Write-Host ""

# Test 4: Check checkpoints.cpp
Write-Host "[4/4] Checking checkpoints.cpp..." -ForegroundColor Yellow
$checkpointsFile = Get-Content "$baseDir\checkpoints.cpp" -Raw

# Check for critical checkpoints
$criticalCheckpoints = @{
    "500000" = "9b6f14f13f0ee345eb03aa2742630480d7e2f7c3ce46e4c34ecbb23d2d871f6c"
    "2000000" = "4ceca77d22d672d391670224ca2f9457209bc1ecf5f5eaf5e9d652b81656995b"
    "4000000" = "959ec2a6d7d67cf4272bcb6508c68daa69a7c280123f26d001c47387186fc1fd"
}

$checkpointsPassed = $true
foreach ($height in $criticalCheckpoints.Keys) {
    $hash = $criticalCheckpoints[$height]
    if ($checkpointsFile -match $height -and $checkpointsFile -match $hash) {
        Write-Host "  ✅ Checkpoint $height found with correct hash" -ForegroundColor Green
    } else {
        Write-Host "  ❌ FAILED: Checkpoint $height missing or incorrect" -ForegroundColor Red
        $checkpointsPassed = $false
        $allPassed = $false
    }
}

# Check timestamp
if ($checkpointsFile -match "1771271617") {
    Write-Host "  ✅ Timestamp 1771271617 confirmed" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAILED: Timestamp not updated" -ForegroundColor Red
    $checkpointsPassed = $false
    $allPassed = $false
}

# Check V1.5 comment
if ($checkpointsFile -match "V1\.5.*Extended checkpoints") {
    Write-Host "  ✅ V1.5 comment present" -ForegroundColor Green
} else {
    Write-Host "  ❌ FAILED: V1.5 comment missing" -ForegroundColor Red
    $checkpointsPassed = $false
    $allPassed = $false
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan

if ($allPassed) {
    Write-Host "✅ ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Blazecoin V1.5 code modifications are correct." -ForegroundColor Green
    Write-Host "Ready for compilation!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Install MinGW and dependencies (OpenSSL, Berkeley DB, Boost, miniupnpc)" -ForegroundColor White
    Write-Host "  2. Run: mingw32-make -f makefile.mingw" -ForegroundColor White
    Write-Host "  3. Test the compiled wallet with isolated configuration" -ForegroundColor White
    Write-Host ""
    Write-Host "OR" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  • Send the modified source to someone with a build environment" -ForegroundColor White
    Write-Host "  • Use cross-compilation on Linux (easier)" -ForegroundColor White
    Write-Host "  • Set up a Linux VM or Docker container for building" -ForegroundColor White
} else {
    Write-Host "❌ SOME TESTS FAILED!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please review the errors above and fix the issues." -ForegroundColor Red
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Show file statistics
Write-Host "Modified Files:" -ForegroundColor Cyan
$files = @(
    "$baseDir\clientversion.h",
    "$baseDir\main.cpp",
    "$baseDir\checkpoints.cpp"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $lastModified = (Get-Item $file).LastWriteTime
        $relativePath = $file -replace [regex]::Escape("C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\"), ""
        Write-Host "  $relativePath" -ForegroundColor White
        Write-Host "    Last modified: $lastModified" -ForegroundColor Gray
    }
}

Write-Host ""
