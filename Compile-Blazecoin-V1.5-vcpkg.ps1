# Blazecoin V1.5 - Compile using vcpkg dependencies
# Run this script after vcpkg dependencies are installed

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Blazecoin V1.5 Compilation (vcpkg)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if vcpkg is installed
if (-not (Test-Path "C:\vcpkg\vcpkg.exe")) {
    Write-Host "[ERROR] vcpkg not found at C:\vcpkg\" -ForegroundColor Red
    Write-Host "Run the vcpkg installation script first." -ForegroundColor Yellow
    exit 1
}

# Add vcpkg tools to PATH
$env:Path = "C:\vcpkg\installed\x64-windows\bin;C:\vcpkg\installed\x64-windows\tools;" + $env:Path
$env:Path = "C:\vcpkg\downloads\tools\mingw\mingw64\bin;" + $env:Path

# Check for g++ compiler
Write-Host "[1/5] Checking for g++ compiler..." -ForegroundColor Yellow
$gppPath = Get-Command g++ -ErrorAction SilentlyContinue
if ($null -eq $gppPath) {
    Write-Host "[INFO] g++ not found in PATH. Installing MinGW via vcpkg..." -ForegroundColor Yellow
    cd C:\vcpkg
    .\vcpkg install mingw-w64:x64-windows
    
    # Try again
    $gppPath = Get-Command g++ -ErrorAction SilentlyContinue
    if ($null -eq $gppPath) {
        Write-Host "[ERROR] Still can't find g++ after installing MinGW" -ForegroundColor Red
        Write-Host "You may need to use MSYS2 MinGW instead." -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "[OK] Found g++: $($gppPath.Source)" -ForegroundColor Green
Write-Host ""

# Verify dependencies
Write-Host "[2/5] Verifying vcpkg dependencies..." -ForegroundColor Yellow
$requiredLibs = @("boost-system", "boost-filesystem", "boost-thread", "boost-program-options", "openssl", "berkeleydb", "miniupnpc")
cd C:\vcpkg
foreach ($lib in $requiredLibs) {
    $installed = .\vcpkg list | Select-String -Pattern "$lib.*x64-windows"
    if ($installed) {
        Write-Host "[OK] $lib installed" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] $lib not found, installing..." -ForegroundColor Yellow
        .\vcpkg install "${lib}:x64-windows"
    }
}
Write-Host ""

# Set up environment variables for compilation
Write-Host "[3/5] Setting up build environment..." -ForegroundColor Yellow
$env:BOOST_ROOT = "C:\vcpkg\installed\x64-windows"
$env:OPENSSL_ROOT = "C:\vcpkg\installed\x64-windows"
$env:BDB_ROOT = "C:\vcpkg\installed\x64-windows"
$env:MINIUPNPC_ROOT = "C:\vcpkg\installed\x64-windows"
$env:INCLUDE = "C:\vcpkg\installed\x64-windows\include;" + $env:INCLUDE
$env:LIB = "C:\vcpkg\installed\x64-windows\lib;" + $env:LIB
Write-Host "[OK] Environment configured" -ForegroundColor Green
Write-Host ""

# Change to source directory
Write-Host "[4/5] Changing to Blazecoin source directory..." -ForegroundColor Yellow
$srcPath = "C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\src"
if (-not (Test-Path $srcPath)) {
    Write-Host "[ERROR] Source directory not found: $srcPath" -ForegroundColor Red
    exit 1
}
cd $srcPath
Write-Host "[OK] In directory: $srcPath" -ForegroundColor Green
Write-Host ""

# Compile
Write-Host "[5/5] Starting compilation..." -ForegroundColor Yellow
Write-Host "This will take 30-60 minutes. Grab a coffee!" -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date

# Try mingw32-make first
$makePath = Get-Command mingw32-make -ErrorAction SilentlyContinue
if ($null -eq $makePath) {
    # Try make
    $makePath = Get-Command make -ErrorAction SilentlyContinue
}

if ($null -ne $makePath) {
    Write-Host "Using make: $($makePath.Source)" -ForegroundColor Gray
    & $makePath.Source -f makefile.mingw
} else {
    Write-Host "[ERROR] No make tool found (tried mingw32-make and make)" -ForegroundColor Red
    Write-Host "Install MinGW or use MSYS2" -ForegroundColor Yellow
    exit 1
}

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " Compilation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Time taken: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan
Write-Host ""

# Check for output
if (Test-Path "blazecoind.exe") {
    $fileSize = (Get-Item "blazecoind.exe").Length / 1MB
    Write-Host "[OK] blazecoind.exe created ($([math]::Round($fileSize, 2)) MB)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Strip debug symbols: strip blazecoind.exe" -ForegroundColor White
    Write-Host "2. Test in isolated environment (ports 55415/55416)" -ForegroundColor White
    Write-Host "3. Monitor sync past 2,000,000 blocks" -ForegroundColor White
} else {
    Write-Host "[ERROR] blazecoind.exe not found after compilation" -ForegroundColor Red
    Write-Host "Check for errors in the output above" -ForegroundColor Yellow
}
