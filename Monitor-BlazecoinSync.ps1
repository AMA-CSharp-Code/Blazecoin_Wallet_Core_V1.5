# Monitor-BlazecoinSync.ps1 - live Blazecoin V1.5 sync monitor for PowerShell
# Usage:  .\Monitor-BlazecoinSync.ps1
# Stops with Ctrl+C. The daemon keeps running.

$blazecoind = "C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\bin\x64\Release\blazecoind.exe"
$conf       = "-conf=C:\blazecoin-data\BlazecoinV1.5\blazecoin.conf"
$datadir    = "-datadir=C:\blazecoin-data\BlazecoinV1.5"
$logFile    = "C:\blazecoin-data\BlazecoinV1.5\debug.log"
$target     = 4105596   # approximate full chain height; bump as the chain grows

$prevHeight = $null
$prevTime   = Get-Date

while ($true) {
    Clear-Host
    $now = Get-Date

    # block count via RPC
    $heightStr = & $blazecoind $conf $datadir getblockcount
    if ($LASTEXITCODE -ne 0 -or -not ($heightStr -match '^\d+$')) {
        Write-Host "Daemon not responding (still starting up, port conflict, or stopped)" -ForegroundColor Yellow
        Write-Host "Last raw output: $heightStr"
        Start-Sleep -Seconds 5
        continue
    }
    $height = [int]$heightStr

    # connection count
    $connsStr = & $blazecoind $conf $datadir getconnectioncount
    $conns = if ($connsStr -match '^\d+$') { [int]$connsStr } else { 0 }

    # blocks/sec since last poll
    $rate = 0
    if ($null -ne $prevHeight -and $height -gt $prevHeight) {
        $deltaBlocks = $height - $prevHeight
        $deltaSec    = ($now - $prevTime).TotalSeconds
        if ($deltaSec -gt 0) { $rate = [math]::Round($deltaBlocks / $deltaSec, 0) }
    }

    # ETA
    $remaining = $target - $height
    if ($rate -gt 0 -and $remaining -gt 0) {
        $etaSec = [int]($remaining / $rate)
        $etaH   = [int]($etaSec / 3600)
        $etaM   = [int](($etaSec % 3600) / 60)
        $etaStr = "~${etaH}h ${etaM}m"
    } else {
        $etaStr = "(calculating)"
    }

    # progress percent
    $pct = [math]::Round(($height / $target) * 100, 2)

    # last 5 SetBestChain entries from log
    $tailLines = @()
    if (Test-Path $logFile) {
        $tailLines = Select-String -Path $logFile -Pattern "SetBestChain" -SimpleMatch |
                     Select-Object -Last 5
    }

    # render
    Write-Host "================================================="          -ForegroundColor Cyan
    Write-Host "  Blazecoin V1.5 sync monitor    $($now.ToString('HH:mm:ss'))" -ForegroundColor Cyan
    Write-Host "================================================="          -ForegroundColor Cyan
    Write-Host ("  Height       : {0:N0} / {1:N0}" -f $height, $target)
    Write-Host ("  Progress     : {0} %" -f $pct)
    Write-Host ("  Connections  : {0}" -f $conns)
    Write-Host ("  Rate         : {0} blocks/sec" -f $rate)
    Write-Host ("  ETA to tip   : {0}" -f $etaStr)
    Write-Host "================================================="          -ForegroundColor Cyan
    Write-Host "  Last 5 connected blocks:"
    foreach ($line in $tailLines) {
        # extract height=NNN  date=YYYY-MM-DD HH:MM:SS
        $h = ""
        $d = ""
        if ($line.Line -match 'height=(\d+)')                { $h = "height=" + $matches[1] }
        if ($line.Line -match 'date=(\S+)\s+(\S+)')          { $d = "date=" + $matches[1] + " " + $matches[2] }
        Write-Host ("    {0,-15}  {1}" -f $h, $d)
    }
    Write-Host "================================================="          -ForegroundColor Cyan
    Write-Host "  Refreshing every 10s.  Ctrl+C to exit."                   -ForegroundColor DarkGray

    $prevHeight = $height
    $prevTime   = $now
    Start-Sleep -Seconds 10
}
