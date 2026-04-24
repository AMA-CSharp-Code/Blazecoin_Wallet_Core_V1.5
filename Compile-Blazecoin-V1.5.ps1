# Blazecoin V1.5 - Compilation Script
# This script compiles the Blazecoin wallet using MSYS2 MinGW64

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Blazecoin V1.5 - Compilation" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Paths
$blazecoinSrc = "C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\src"
$msys2Path = "C:\msys64"
$msys2Shell = "$msys2Path\usr\bin\bash.exe"
$outputDir = "C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\compiled"

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow
Write-Host ""

if (-not (Test-Path $blazecoinSrc)) {
    Write-Host "❌ Blazecoin source not found: $blazecoinSrc" -ForegroundColor Red
    exit
}
Write-Host "✅ Source directory found" -ForegroundColor Green

if (-not (Test-Path $msys2Shell)) {
    Write-Host "❌ MSYS2 not found: $msys2Shell" -ForegroundColor Red
    Write-Host "Please run Setup-MinGW-Environment.ps1 first." -ForegroundColor Yellow
    exit
}
Write-Host "✅ MSYS2 found" -ForegroundColor Green

$mingwBin = "$msys2Path\mingw64\bin"
if (-not (Test-Path "$mingwBin\g++.exe")) {
    Write-Host "❌ MinGW compiler not found" -ForegroundColor Red
    Write-Host "Please run Install-Blazecoin-Dependencies-MSYS2.ps1 first." -ForegroundColor Yellow
    exit
}
Write-Host "✅ MinGW compiler found" -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Code Verification" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Run verification script
Write-Host "Verifying V1.5 code changes..." -ForegroundColor Yellow
$verifyScript = "C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\Verify-V1.5-Changes.ps1"
if (Test-Path $verifyScript) {
    & $verifyScript
    Write-Host ""
    $continueCompile = Read-Host "Continue with compilation? (y/n)"
    if ($continueCompile -ne 'y') {
        Write-Host "Compilation cancelled." -ForegroundColor Yellow
        exit
    }
} else {
    Write-Host "⚠️  Verification script not found. Proceeding anyway..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Compilation - Daemon (blazecoind.exe)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Starting compilation..." -ForegroundColor Yellow
Write-Host "This may take 10-30 minutes depending on your system." -ForegroundColor Gray
Write-Host ""

# Create output directory
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# Compile using MSYS2
$compileCommand = @"
cd /c/Users/Andrew/source/repos/Blazecoin_Core_V1.5/src && \
export PATH=/mingw64/bin:\$PATH && \
make -f makefile.mingw clean && \
make -f makefile.mingw USE_UPNP=1 2>&1 | tee compile.log
"@

Write-Host "Executing: make -f makefile.mingw" -ForegroundColor Yellow
Write-Host ""

$compileStart = Get-Date
& $msys2Shell -lc $compileCommand

$compileEnd = Get-Date
$compileDuration = $compileEnd - $compileStart

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan

# Check if compilation succeeded
if (Test-Path "$blazecoinSrc\blazecoind.exe") {
    Write-Host "✅ COMPILATION SUCCESSFUL!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Compilation time: $($compileDuration.ToString('mm\:ss'))" -ForegroundColor Gray
    Write-Host ""
    
    # Copy to output directory
    Write-Host "Copying binaries to output directory..." -ForegroundColor Yellow
    Copy-Item "$blazecoinSrc\blazecoind.exe" "$outputDir\blazecoind.exe" -Force
    
    # Strip debug symbols to reduce size
    Write-Host "Stripping debug symbols..." -ForegroundColor Yellow
    & "$mingwBin\strip.exe" "$outputDir\blazecoind.exe"
    
    $exeSize = (Get-Item "$outputDir\blazecoind.exe").Length / 1MB
    Write-Host ""
    Write-Host "✅ blazecoind.exe created" -ForegroundColor Green
    Write-Host "   Size: $([math]::Round($exeSize, 2)) MB" -ForegroundColor Gray
    Write-Host "   Location: $outputDir\blazecoind.exe" -ForegroundColor Gray
    
} else {
    Write-Host "❌ COMPILATION FAILED!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check the compilation log for errors:" -ForegroundColor Yellow
    Write-Host "  $blazecoinSrc\compile.log" -ForegroundColor White
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  • Missing dependencies - run Install-Blazecoin-Dependencies-MSYS2.ps1" -ForegroundColor White
    Write-Host "  • Syntax errors in code - check modifications" -ForegroundColor White
    Write-Host "  • Library version mismatch - ensure MSYS2 packages are up to date" -ForegroundColor White
    exit
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Compilation - GUI Wallet (blazecoin-qt.exe)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Do you want to compile the GUI wallet too?" -ForegroundColor Yellow
Write-Host "This requires Qt5 (installed via MSYS2)" -ForegroundColor Gray
$compileGui = Read-Host "Compile GUI wallet? (y/n)"

if ($compileGui -eq 'y') {
    Write-Host ""
    Write-Host "Compiling GUI wallet..." -ForegroundColor Yellow
    Write-Host "This may take 15-40 minutes..." -ForegroundColor Gray
    Write-Host ""
    
    # Check if .pro file exists
    $proFile = "C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\blazecoin-qt.pro"
    if (-not (Test-Path $proFile)) {
        Write-Host "❌ blazecoin-qt.pro not found" -ForegroundColor Red
        Write-Host "GUI compilation skipped." -ForegroundColor Yellow
    } else {
        $guiCompileCommand = @"
cd /c/Users/Andrew/source/repos/Blazecoin_Core_V1.5 && \
export PATH=/mingw64/bin:\$PATH && \
qmake blazecoin-qt.pro 'USE_UPNP=1' 'USE_QRCODE=1' && \
make 2>&1 | tee compile-gui.log
"@
        
        $guiStart = Get-Date
        & $msys2Shell -lc $guiCompileCommand
        $guiEnd = Get-Date
        $guiDuration = $guiEnd - $guiStart
        
        if (Test-Path "C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\release\blazecoin-qt.exe") {
            Write-Host ""
            Write-Host "✅ GUI WALLET COMPILED!" -ForegroundColor Green
            Write-Host "Compilation time: $($guiDuration.ToString('mm\:ss'))" -ForegroundColor Gray
            
            Copy-Item "C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\release\blazecoin-qt.exe" "$outputDir\blazecoin-qt.exe" -Force
            & "$mingwBin\strip.exe" "$outputDir\blazecoin-qt.exe"
            
            $qtSize = (Get-Item "$outputDir\blazecoin-qt.exe").Length / 1MB
            Write-Host "✅ blazecoin-qt.exe created" -ForegroundColor Green
            Write-Host "   Size: $([math]::Round($qtSize, 2)) MB" -ForegroundColor Gray
        } else {
            Write-Host "❌ GUI compilation failed" -ForegroundColor Red
            Write-Host "Check: C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\compile-gui.log" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Build Summary" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Output Directory: $outputDir" -ForegroundColor White
Write-Host ""

if (Test-Path "$outputDir\blazecoind.exe") {
    Write-Host "✅ blazecoind.exe - Command-line daemon" -ForegroundColor Green
}
if (Test-Path "$outputDir\blazecoin-qt.exe") {
    Write-Host "✅ blazecoin-qt.exe - GUI wallet" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Next Steps - Testing" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Create test configuration directory:" -ForegroundColor Cyan
Write-Host "   New-Item -ItemType Directory -Path 'C:\blazecoin-data\BlazecoinV1.5' -Force" -ForegroundColor White
Write-Host ""

Write-Host "2. Create test configuration file:" -ForegroundColor Cyan
Write-Host "   Create: C:\blazecoin-data\BlazecoinV1.5\blazecoin.conf" -ForegroundColor White
Write-Host "   Contents:" -ForegroundColor Gray
Write-Host "   rpcport=55415" -ForegroundColor Gray
Write-Host "   port=55416" -ForegroundColor Gray
Write-Host "   rpcuser=username" -ForegroundColor Gray
Write-Host "   rpcpassword=password" -ForegroundColor Gray
Write-Host "   server=1" -ForegroundColor Gray
Write-Host "   daemon=1" -ForegroundColor Gray
Write-Host "   txindex=1" -ForegroundColor Gray
Write-Host "   addnode=85.15.179.171:55414" -ForegroundColor Gray
Write-Host "   addnode=91.206.16.214:55414" -ForegroundColor Gray
Write-Host ""

Write-Host "3. Start V1.5 wallet (TEST MODE):" -ForegroundColor Cyan
Write-Host "   $outputDir\blazecoind.exe -datadir=C:\blazecoin-data\BlazecoinV1.5" -ForegroundColor White
Write-Host ""

Write-Host "4. Monitor sync progress:" -ForegroundColor Cyan
Write-Host "   $outputDir\blazecoind.exe -rpcport=55415 getinfo" -ForegroundColor White
Write-Host "   $outputDir\blazecoind.exe -rpcport=55415 getblockcount" -ForegroundColor White
Write-Host ""

Write-Host "5. Watch for critical milestone:" -ForegroundColor Cyan
Write-Host "   ⭐ Wallet syncs PAST block 2,000,000 without stopping!" -ForegroundColor White
Write-Host ""

Write-Host "Full testing guide: See CHANGES_V1.5.md 'Testing Plan' section" -ForegroundColor Gray
Write-Host ""
