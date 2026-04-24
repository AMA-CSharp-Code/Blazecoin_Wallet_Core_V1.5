# Blazecoin V1.5 - Install MSYS2 to Alternative Location
# Run as Administrator
# Installs to C:\msys64-new (avoid locked C:\msys64)

Write-Host "[INFO] Installing MSYS2 to C:\msys64-new..." -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if alternative location exists
if (Test-Path "C:\msys64-new") {
    Write-Host "[WARNING] C:\msys64-new already exists. Delete it first." -ForegroundColor Yellow
    exit 1
}

# Step 2: Download MSYS2 installer
Write-Host "[1/3] Downloading MSYS2 installer (~500 MB)..." -ForegroundColor Yellow
$installerUrl = "https://github.com/msys2/msys2-installer/releases/download/2024-01-13/msys2-x86_64-20240113.exe"
$installerPath = "$env:TEMP\msys2-installer.exe"

if (Test-Path $installerPath) {
    Write-Host "      Using cached installer..." -ForegroundColor Gray
} else {
    Write-Host "      Downloading from GitHub..." -ForegroundColor Gray
    try {
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
        Write-Host "[OK] Download complete." -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Download failed: $_" -ForegroundColor Red
        exit 1
    }
}
Write-Host ""

# Step 3: Install MSYS2 to alternative location
Write-Host "[2/3] Installing MSYS2 to C:\msys64-new..." -ForegroundColor Yellow
Write-Host "      This will take 2-3 minutes..." -ForegroundColor Gray
try {
    $installArgs = @(
        "install",
        "--root", "C:\msys64-new",
        "--confirm-command"
    )
    Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -NoNewWindow
    Write-Host "[OK] MSYS2 installed to C:\msys64-new" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Installation failed: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 4: Verify installation
Write-Host "[3/3] Verifying installation..." -ForegroundColor Yellow
$requiredFiles = @(
    "C:\msys64-new\msys2.exe",
    "C:\msys64-new\mingw64.exe",
    "C:\msys64-new\usr\bin\bash.exe",
    "C:\msys64-new\usr\bin\pacman.exe"
)

$allPresent = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "[OK] Found: $(Split-Path $file -Leaf)" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Missing: $file" -ForegroundColor Red
        $allPresent = $false
    }
}

if (-not $allPresent) {
    Write-Host ""
    Write-Host "[ERROR] Installation incomplete." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host " MSYS2 Installation Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: MSYS2 installed to C:\msys64-new (not C:\msys64)" -ForegroundColor Yellow
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open terminal manually:" -ForegroundColor White
Write-Host "   C:\msys64-new\mingw64.exe" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Run these commands ONE AT A TIME:" -ForegroundColor White
Write-Host ""
Write-Host "   pacman -Syu --noconfirm" -ForegroundColor Yellow
Write-Host "   (terminal will close - reopen it)" -ForegroundColor Gray
Write-Host ""
Write-Host "   pacman -Su --noconfirm" -ForegroundColor Yellow
Write-Host ""
Write-Host "   pacman -S --noconfirm mingw-w64-x86_64-toolchain base-devel" -ForegroundColor Yellow
Write-Host ""
Write-Host "   pacman -S --noconfirm mingw-w64-x86_64-boost mingw-w64-x86_64-openssl mingw-w64-x86_64-db mingw-w64-x86_64-miniupnpc" -ForegroundColor Yellow
Write-Host ""
Write-Host "   g++ --version" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. After dependencies installed, update paths in compilation script" -ForegroundColor White
Write-Host "   (Change C:\msys64 to C:\msys64-new)" -ForegroundColor Gray
Write-Host ""

# Keep window open
Write-Host "Press any key to close..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
