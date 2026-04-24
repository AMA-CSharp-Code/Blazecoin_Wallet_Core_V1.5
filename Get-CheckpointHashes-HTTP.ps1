# Blazecoin V1.5 - Checkpoint Hash Extractor (HTTP JSON-RPC Version)
# This script queries your running Blazecoin wallet via HTTP JSON-RPC
# These hashes will be used as checkpoints in the V1.5 wallet code

# Configuration
$rpcUrl = "http://127.0.0.1:55413"
$rpcUser = "username"
$rpcPassword = "password"

# Checkpoint heights
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

# Create credential for Basic Auth
$securePassword = ConvertTo-SecureString $rpcPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($rpcUser, $securePassword)

# Function to call RPC
function Invoke-BlazecoinRPC {
    param(
        [string]$Method,
        [array]$Params = @()
    )
    
    $body = @{
        jsonrpc = "1.0"
        id = "checkpoint-extractor"
        method = $Method
        params = $Params
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri $rpcUrl -Method Post -Body $body -ContentType "application/json" -Credential $credential
        return $response.result
    } catch {
        throw "RPC Error: $_"
    }
}

# Get current block count
Write-Host "Checking current blockchain height..." -ForegroundColor Yellow
try {
    $currentHeight = Invoke-BlazecoinRPC -Method "getblockcount"
    Write-Host "Current Height: $currentHeight blocks" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERROR: Cannot connect to Blazecoin wallet!" -ForegroundColor Red
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "  1. Blazecoin wallet is running" -ForegroundColor Yellow
    Write-Host "  2. RPC server is enabled (server=1 in blazecoin.conf)" -ForegroundColor Yellow
    Write-Host "  3. RPC credentials match (rpcuser/rpcpassword in blazecoin.conf)" -ForegroundColor Yellow
    Write-Host "  4. RPC port is correct (rpcport=55413 in blazecoin.conf)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}

# Collect checkpoint data
$checkpoints = @()
$outputFile = "Blazecoin_V1.5_Checkpoints.txt"

foreach ($height in $checkpointHeights) {
    if ($height -gt $currentHeight) {
        Write-Host "Skipping height $height (not yet reached)" -ForegroundColor Gray
        continue
    }
    
    Write-Host "Getting hash for block $height..." -ForegroundColor Yellow

    try {
        $hash = Invoke-BlazecoinRPC -Method "getblockhash" -Params @($height)
        $blockInfo = Invoke-BlazecoinRPC -Method "getblock" -Params @($hash)
        
        $checkpoint = [PSCustomObject]@{
            Height = $height
            Hash = $hash
            Timestamp = $blockInfo.time
            DateTime = [DateTimeOffset]::FromUnixTimeSeconds($blockInfo.time).DateTime
            TxCount = $blockInfo.tx.Count
        }
        
        $checkpoints += $checkpoint
        
        Write-Host "  Hash: $hash" -ForegroundColor Green
        Write-Host "  Time: $($checkpoint.DateTime)" -ForegroundColor Green
        Write-Host "  Transactions: $($checkpoint.TxCount)" -ForegroundColor Green
        Write-Host ""
    } catch {
        Write-Host "  ERROR getting block $height : $_" -ForegroundColor Red
        Write-Host ""
    }
}

# Generate output
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Generating checkpoint data..." -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

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
    $output += "`n    ( $($cp.Height.ToString().PadLeft(7)),  uint256(`"0x$($cp.Hash)`"))"
}

# Calculate last checkpoint timestamp and total transactions
if ($checkpoints.Count -gt 0) {
    $lastCheckpoint = $checkpoints[-1]
    $totalTx = ($checkpoints | Measure-Object -Property TxCount -Sum).Sum
    
    $output += @"

    ;

static const CCheckpointData data = {
    &mapCheckpoints,
    $($lastCheckpoint.Timestamp), // * UNIX timestamp of last checkpoint block ($($lastCheckpoint.DateTime))
    $totalTx,    // * total number of transactions between genesis and last checkpoint
    100   // * estimated number of transactions per day after checkpoint
};
"@
} else {
    $output += @"

    ;

static const CCheckpointData data = {
    &mapCheckpoints,
    , // * UNIX timestamp of last checkpoint block
    0,    // * total number of transactions - UPDATE THIS MANUALLY
    100   // * estimated number of transactions per day
};
"@
}

$output += @"


CHECKPOINT DETAILS
=====================================

"@

foreach ($cp in $checkpoints) {
    $output += @"
Block Height: $($cp.Height)
  Hash:       $($cp.Hash)
  Timestamp:  $($cp.Timestamp) ($($cp.DateTime))
  TX Count:   $($cp.TxCount)

"@
}

# Save to file
$output | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "✅ Checkpoint data saved to: $outputFile" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Review the generated checkpoint data in $outputFile" -ForegroundColor White
Write-Host "  2. Copy the C++ code section into src/checkpoints.cpp" -ForegroundColor White
Write-Host "  3. Replace the existing mapCheckpoints and CCheckpointData sections" -ForegroundColor White
Write-Host "  4. Compile the V1.5 wallet" -ForegroundColor White
Write-Host ""
