# Blazecoin V1.5 - Install Dependencies via MSYS2
# This script uses MSYS2's package manager to install all required libraries

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Blazecoin V1.5 - MSYS2 Dependencies" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if MSYS2 is installed
$msys2Path = "C:\msys64"
$msys2Shell = "$msys2Path\usr\bin\bash.exe"

if (-not (Test-Path $msys2Shell)) {
    Write-Host "❌ MSYS2 not found!" -ForegroundColor Red
    Write-Host "Please run Setup-MinGW-Environment.ps1 first." -ForegroundColor Yellow
    exit
}

Write-Host "✅ MSYS2 found: $msys2Path" -ForegroundColor Green
Write-Host ""

Write-Host "This will install the following packages via MSYS2:" -ForegroundColor Yellow
Write-Host "  • mingw-w64-x86_64-toolchain (GCC compiler)" -ForegroundColor White
Write-Host "  • mingw-w64-x86_64-boost" -ForegroundColor White
Write-Host "  • mingw-w64-x86_64-openssl" -ForegroundColor White
Write-Host "  • mingw-w64-x86_64-db (Berkeley DB)" -ForegroundColor White
Write-Host "  • mingw-w64-x86_64-miniupnpc" -ForegroundColor White
Write-Host "  • mingw-w64-x86_64-qt5 (for GUI wallet)" -ForegroundColor White
Write-Host "  • base-devel (make, autoconf, etc.)" -ForegroundColor White
Write-Host ""
Write-Host "Download size: ~2 GB" -ForegroundColor Yellow
Write-Host "Installation time: 10-20 minutes" -ForegroundColor Yellow
Write-Host ""

$continue = Read-Host "Continue with installation? (y/n)"
if ($continue -ne 'y') {
    Write-Host "Installation cancelled." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Updating MSYS2 Package Database" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Update MSYS2
Write-Host "Updating MSYS2 package database..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Gray
Write-Host ""

$updateCommand = "pacman -Syu --noconfirm"
& $msys2Shell -lc $updateCommand

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Initial update completed with warnings (this is normal)" -ForegroundColor Yellow
    Write-Host "Running second update pass..." -ForegroundColor Yellow
    & $msys2Shell -lc $updateCommand
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Installing Development Tools" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Install base development tools
Write-Host "Installing base-devel (make, autoconf, etc.)..." -ForegroundColor Yellow
$installBaseCommand = "pacman -S --noconfirm --needed base-devel"
& $msys2Shell -lc $installBaseCommand

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Installing MinGW-w64 Toolchain" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Install MinGW-w64 toolchain
Write-Host "Installing MinGW-w64 GCC compiler..." -ForegroundColor Yellow
$installToolchainCommand = "pacman -S --noconfirm --needed mingw-w64-x86_64-toolchain"
& $msys2Shell -lc $installToolchainCommand

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Installing Blazecoin Dependencies" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Install all dependencies in one command
Write-Host "Installing OpenSSL, Berkeley DB, Boost, miniupnpc, Qt5..." -ForegroundColor Yellow
Write-Host "This is the largest download - please be patient..." -ForegroundColor Gray
Write-Host ""

$installDepsCommand = @"
pacman -S --noconfirm --needed \
  mingw-w64-x86_64-boost \
  mingw-w64-x86_64-openssl \
  mingw-w64-x86_64-db \
  mingw-w64-x86_64-miniupnpc \
  mingw-w64-x86_64-qt5 \
  mingw-w64-x86_64-protobuf \
  mingw-w64-x86_64-qrencode
"@

& $msys2Shell -lc $installDepsCommand

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Verifying Installation" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if key files exist
$mingwBin = "$msys2Path\mingw64\bin"
$requiredFiles = @{
    "g++.exe" = "GCC C++ Compiler"
    "mingw32-make.exe" = "Make build tool"
    "libboost_system-mt.dll" = "Boost library"
    "libcrypto-3-x64.dll" = "OpenSSL crypto"
    "libdb-6.2.dll" = "Berkeley DB"
    "libminiupnpc.dll" = "miniupnpc"
    "Qt5Core.dll" = "Qt5 Framework"
}

$allFound = $true
foreach ($file in $requiredFiles.Keys) {
    $fullPath = "$mingwBin\$file"
    if (Test-Path $fullPath) {
        Write-Host "  ✅ $($requiredFiles[$file]): Found" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $($requiredFiles[$file]): NOT FOUND" -ForegroundColor Red
        $allFound = $false
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Environment Configuration" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Add MSYS2 MinGW64 to PATH
$mingw64Path = "$msys2Path\mingw64\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*$mingw64Path*") {
    Write-Host "Adding MSYS2 MinGW64 to PATH..." -ForegroundColor Yellow
    try {
        [Environment]::SetEnvironmentVariable("Path", "$mingw64Path;$currentPath", "User")
        $env:Path = "$mingw64Path;$env:Path"
        Write-Host "✅ PATH updated" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to update PATH automatically" -ForegroundColor Red
        Write-Host "Please add manually: $mingw64Path" -ForegroundColor Yellow
    }
} else {
    Write-Host "✅ MSYS2 MinGW64 already in PATH" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan

if ($allFound) {
    Write-Host "✅ ALL DEPENDENCIES INSTALLED!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You're ready to compile Blazecoin V1.5!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Close and reopen PowerShell (for PATH changes)" -ForegroundColor White
    Write-Host "  2. Navigate to: C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5" -ForegroundColor White
    Write-Host "  3. Run: .\Compile-Blazecoin-V1.5.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Or compile manually in MSYS2 MinGW64 shell:" -ForegroundColor Cyan
    Write-Host "  cd /c/Users/Andrew/source/repos/Blazecoin_Core_V1.5/src" -ForegroundColor White
    Write-Host "  make -f makefile.mingw" -ForegroundColor White
} else {
    Write-Host "⚠️  SOME DEPENDENCIES MISSING" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please check the errors above and try running:" -ForegroundColor Yellow
    Write-Host "  pacman -S --noconfirm mingw-w64-x86_64-boost mingw-w64-x86_64-openssl mingw-w64-x86_64-db" -ForegroundColor White
    Write-Host "in MSYS2 manually." -ForegroundColor Yellow
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
