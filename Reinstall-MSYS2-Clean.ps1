# Blazecoin V1.5 - Clean MSYS2 Reinstallation
# Run as Administrator

Write-Host "[INFO] Starting clean MSYS2 reinstallation..." -ForegroundColor Cyan
Write-Host ""

# Step 1: Remove broken installation
Write-Host "[1/4] Removing broken MSYS2 installation..." -ForegroundColor Yellow
if (Test-Path "C:\msys64") {
    Write-Host "      Deleting C:\msys64..." -ForegroundColor Gray
    Remove-Item -Path "C:\msys64" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    if (Test-Path "C:\msys64") {
        Write-Host "[ERROR] Could not delete C:\msys64. Close any programs using it." -ForegroundColor Red
        exit 1
    }
    Write-Host "[OK] Old installation removed." -ForegroundColor Green
} else {
    Write-Host "[OK] No existing installation found." -ForegroundColor Green
}
Write-Host ""

# Step 2: Download fresh MSYS2 installer
Write-Host "[2/4] Downloading MSYS2 installer (~500 MB)..." -ForegroundColor Yellow
$installerUrl = "https://github.com/msys2/msys2-installer/releases/download/2024-01-13/msys2-x86_64-20240113.exe"
$installerPath = "$env:TEMP\msys2-installer.exe"

if (Test-Path $installerPath) {
    Remove-Item $installerPath -Force
}

Write-Host "      Downloading from GitHub..." -ForegroundColor Gray
try {
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
    Write-Host "[OK] Download complete: $installerPath" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Download failed: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 3: Install MSYS2
Write-Host "[3/4] Installing MSYS2 to C:\msys64..." -ForegroundColor Yellow
Write-Host "      This will take 2-3 minutes..." -ForegroundColor Gray
try {
    $installArgs = @(
        "install",
        "--root", "C:\msys64",
        "--confirm-command"
    )
    Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -NoNewWindow
    Write-Host "[OK] MSYS2 installed successfully." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Installation failed: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 4: Verify installation
Write-Host "[4/4] Verifying installation..." -ForegroundColor Yellow
$requiredFiles = @(
    "C:\msys64\msys2.exe",
    "C:\msys64\mingw64.exe",
    "C:\msys64\usr\bin\bash.exe",
    "C:\msys64\usr\bin\mintty.exe",
    "C:\msys64\usr\bin\pacman.exe"
)

$allPresent = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "[OK] $file" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Missing: $file" -ForegroundColor Red
        $allPresent = $false
    }
}

if (-not $allPresent) {
    Write-Host ""
    Write-Host "[ERROR] Installation incomplete. Some files are missing." -ForegroundColor Red
    exit 1
}

# Check installation size
$installSize = (Get-ChildItem "C:\msys64" -Recurse -ErrorAction SilentlyContinue | 
                Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host ""
Write-Host "[INFO] Installation size: $([math]::Round($installSize, 0)) MB" -ForegroundColor Cyan

if ($installSize -lt 400) {
    Write-Host "[WARNING] Installation seems small. Expected ~500 MB." -ForegroundColor Yellow
} else {
    Write-Host "[OK] Installation size looks good." -ForegroundColor Green
}

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host " MSYS2 Reinstallation Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Open MSYS2 from Start Menu: 'MSYS2 MinGW 64-bit'" -ForegroundColor White
Write-Host "2. Run these commands ONE AT A TIME:" -ForegroundColor White
Write-Host ""
Write-Host "   pacman -Syu --noconfirm" -ForegroundColor Yellow
Write-Host "   (terminal will close - this is normal)" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Reopen 'MSYS2 MinGW 64-bit' and run:" -ForegroundColor White
Write-Host ""
Write-Host "   pacman -Su --noconfirm" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. Install compiler and dependencies:" -ForegroundColor White
Write-Host ""
Write-Host "   pacman -S --noconfirm mingw-w64-x86_64-toolchain base-devel" -ForegroundColor Yellow
Write-Host "   pacman -S --noconfirm mingw-w64-x86_64-boost mingw-w64-x86_64-openssl mingw-w64-x86_64-db mingw-w64-x86_64-miniupnpc" -ForegroundColor Yellow
Write-Host ""
Write-Host "5. Verify compiler:" -ForegroundColor White
Write-Host ""
Write-Host "   g++ --version" -ForegroundColor Yellow
Write-Host ""
Write-Host "Total time: ~20-30 minutes (mostly downloads)" -ForegroundColor Gray
Write-Host ""
