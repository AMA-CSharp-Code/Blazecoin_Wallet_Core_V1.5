# Blazecoin V1.5 - Checkpoint Hash Extractor
# This script queries your production Blazecoin daemon to get block hashes at strategic heights
# These hashes will be used as checkpoints in the V1.5 wallet code

# Configuration
$blazecoindPath = "C:\Users\Andrew\Desktop\Blazecoin\blazecoin-qt.exe"  # Path to blazecoin-qt.exe (GUI wallet with RPC server)
$rpcPort = 55413  # Production RPC port
$rpcUser = "username"  # Your RPC username
$rpcPassword = "password"  # Your RPC password

# Checkpoint heights (add more as needed)
$checkpointHeights = @(
    500000,
    1000000,
    1500000,
    2000000,
    2500000,
    3000000,
    3500000,
    4000000
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Blazecoin V1.5 Checkpoint Hash Extractor" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if blazecoin wallet exists
if (-not (Test-Path $blazecoindPath)) {
    Write-Host "ERROR: Blazecoin wallet not found at: $blazecoindPath" -ForegroundColor Red
    Write-Host "Please update the `$blazecoindPath variable in this script." -ForegroundColor Yellow
    exit 1
}

# Get current block count
Write-Host "Checking current blockchain height..." -ForegroundColor Yellow
try {
    $currentHeight = & $blazecoindPath -rpcport=$rpcPort -rpcuser=$rpcUser -rpcpassword=$rpcPassword getblockcount
    Write-Host "Current Height: $currentHeight blocks" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: Cannot connect to Blazecoin daemon!" -ForegroundColor Red
    Write-Host "Make sure the daemon is running on port $rpcPort" -ForegroundColor Yellow
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}

# Collect checkpoint data
$checkpoints = @()

foreach ($height in $checkpointHeights) {
    if ($height -gt $currentHeight) {
        Write-Host "Skipping height $height (not yet reached)" -ForegroundColor Gray
        continue
    }
    
    Write-Host "Getting hash for block $height..." -ForegroundColor Yellow

    try {
        $hash = & $blazecoindPath -rpcport=$rpcPort -rpcuser=$rpcUser -rpcpassword=$rpcPassword getblockhash $height
        $blockInfo = & $blazecoindPath -rpcport=$rpcPort -rpcuser=$rpcUser -rpcpassword=$rpcPassword getblock $hash
        
        # Parse block info (assuming JSON output)
        $blockData = $blockInfo | ConvertFrom-Json
        $timestamp = $blockData.time
        $dateTime = [DateTimeOffset]::FromUnixTimeSeconds($timestamp).DateTime
        
        $checkpoint = [PSCustomObject]@{
            Height = $height
            Hash = $hash
            Timestamp = $timestamp
            DateTime = $dateTime
        }
        
        $checkpoints += $checkpoint
        
        Write-Host "  Hash: $hash" -ForegroundColor Green
        Write-Host "  Time: $dateTime" -ForegroundColor Green
        Write-Host ""
    } catch {
        Write-Host "  ERROR: Failed to get block $height" -ForegroundColor Red
        Write-Host "  $_" -ForegroundColor Red
        Write-Host ""
    }
}

# Display C++ code format
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "C++ Code for checkpoints.cpp" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Copy and paste this into src/checkpoints.cpp:" -ForegroundColor Yellow
Write-Host ""
Write-Host "static MapCheckpoints mapCheckpoints =" -ForegroundColor White
Write-Host "    boost::assign::map_list_of" -ForegroundColor White
Write-Host "    (  0,      uint256(`"0x5d871c1b6ea542c2bb8a3b3ac70028a591bbf81369e90c2446c1a2bbfb89459b`"))" -ForegroundColor White
Write-Host "    (  1,      uint256(`"0x50f5ef3a2b2637c92907e9d444e6a58f925cb61eaac7b23f46263f2e7d9245c0`"))" -ForegroundColor White
Write-Host "    ( 18500,   uint256(`"0x6cfc4decf7c26c037c621190681f9b3f12912f8330b06c652e0c193340a23347`"))" -ForegroundColor White
Write-Host "    ( 33000,   uint256(`"0xcfd0eb628a7fee82accc4e2f183cdd1abd08afeedf2b1b030230836a4e74629e`"))" -ForegroundColor White
Write-Host "    ( 60413,   uint256(`"0x99ea9310aac366b03161254d77ada05c9eb1392ca8ca370885b013f80d41f56e`"))" -ForegroundColor White
Write-Host "    ( 124650,  uint256(`"0x0d8aa2452b7f2702a9a07a4cb36ad1edd12503014ba46da46992c9dba898dec2`"))" -ForegroundColor White
Write-Host "    ( 215000,  uint256(`"0x7e960cd973982501d2339906c3c7bf81c2e0c0a0a02192198263ae51f024e991`"))" -ForegroundColor White
Write-Host "    ( 363120,  uint256(`"0x40c6d6d81494d53781af0fc9d7aff91a2f3a13e38100b20c3ac819f944ecf9f4`"))" -ForegroundColor White

foreach ($cp in $checkpoints) {
    Write-Host "    ( $($cp.Height.ToString().PadLeft(7)), uint256(`"0x$($cp.Hash)`"))  // $($cp.DateTime.ToString('yyyy-MM-dd'))" -ForegroundColor Green
}

Write-Host "    ;" -ForegroundColor White
Write-Host ""

# Display metadata
if ($checkpoints.Count -gt 0) {
    $lastCheckpoint = $checkpoints[-1]
    Write-Host "Update CCheckpointData:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "static const CCheckpointData data = {" -ForegroundColor White
    Write-Host "    &mapCheckpoints," -ForegroundColor White
    Write-Host "    $($lastCheckpoint.Timestamp), // * UNIX timestamp of last checkpoint block" -ForegroundColor Green
    Write-Host "    0,    // * total number of transactions - UPDATE THIS MANUALLY" -ForegroundColor White
    Write-Host "    100   // * estimated number of transactions per day" -ForegroundColor White
    Write-Host "};" -ForegroundColor White
    Write-Host ""
}

# Export to file
$outputFile = "Blazecoin_V1.5_Checkpoints.txt"
$output = @"
Blazecoin V1.5 Checkpoint Data
Generated: $(Get-Date)
Current Blockchain Height: $currentHeight

C++ CODE FOR src/checkpoints.cpp
=====================================

static MapCheckpoints mapCheckpoints =
    boost::assign::map_list_of
    (  0,      uint256("0x5d871c1b6ea542c2bb8a3b3ac70028a591bbf81369e90c2446c1a2bbfb89459b"))
    (  1,      uint256("0x50f5ef3a2b2637c92907e9d444e6a58f925cb61eaac7b23f46263f2e7d9245c0"))
    ( 18500,   uint256("0x6cfc4decf7c26c037c621190681f9b3f12912f8330b06c652e0c193340a23347"))
    ( 33000,   uint256("0xcfd0eb628a7fee82accc4e2f183cdd1abd08afeedf2b1b030230836a4e74629e"))
    ( 60413,   uint256("0x99ea9310aac366b03161254d77ada05c9eb1392ca8ca370885b013f80d41f56e"))
    ( 124650,  uint256("0x0d8aa2452b7f2702a9a07a4cb36ad1edd12503014ba46da46992c9dba898dec2"))
    ( 215000,  uint256("0x7e960cd973982501d2339906c3c7bf81c2e0c0a0a02192198263ae51f024e991"))
    ( 363120,  uint256("0x40c6d6d81494d53781af0fc9d7aff91a2f3a13e38100b20c3ac819f944ecf9f4"))
"@

foreach ($cp in $checkpoints) {
    $output += "`n    ( $($cp.Height.ToString().PadLeft(7)), uint256(`"0x$($cp.Hash)`"))  // $($cp.DateTime.ToString('yyyy-MM-dd'))"
}

$output += @"

    ;

static const CCheckpointData data = {
    &mapCheckpoints,
    $($lastCheckpoint.Timestamp), // * UNIX timestamp of last checkpoint block
    0,    // * total number of transactions - UPDATE THIS MANUALLY
    100   // * estimated number of transactions per day
};

CHECKPOINT DETAILS
=====================================

"@

foreach ($cp in $checkpoints) {
    $output += @"
Height: $($cp.Height)
Hash: 0x$($cp.Hash)
Timestamp: $($cp.Timestamp)
Date/Time: $($cp.DateTime)

"@
}

$output | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Data saved to: $outputFile" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
