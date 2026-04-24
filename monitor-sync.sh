#!/usr/bin/env bash
# monitor-sync.sh — live Blazecoin V1.5 sync monitor
# Usage: ./monitor-sync.sh

CLI="./bin/x64/Release/blazecoind.exe"
CONF='-conf=C:\blazecoin-data\BlazecoinV1.5\blazecoin.conf'
DDIR='-datadir=C:\blazecoin-data\BlazecoinV1.5'
LOG="/c/blazecoin-data/BlazecoinV1.5/debug.log"
TARGET=4105596   # approximate full chain height (update as needed)

prev_height=""
prev_time=$(date +%s)

while true; do
    clear
    now=$(date +%s)

    # block count via RPC
    height=$($CLI "$CONF" "$DDIR" getblockcount 2>/dev/null)
    if [ -z "$height" ] || ! [[ "$height" =~ ^[0-9]+$ ]]; then
        echo "Daemon not responding (still starting up, or stopped)"
        sleep 5
        continue
    fi

    # connections
    conns=$($CLI "$CONF" "$DDIR" getconnectioncount 2>/dev/null)

    # blocks/sec since last poll
    if [ -n "$prev_height" ] && [ "$height" -gt "$prev_height" ]; then
        delta_blocks=$((height - prev_height))
        delta_time=$((now - prev_time))
        if [ "$delta_time" -gt 0 ]; then
            rate=$((delta_blocks / delta_time))
        else
            rate=0
        fi
    else
        rate=0
    fi

    # ETA
    remaining=$((TARGET - height))
    if [ "$rate" -gt 0 ] && [ "$remaining" -gt 0 ]; then
        eta_sec=$((remaining / rate))
        eta_h=$((eta_sec / 3600))
        eta_m=$(( (eta_sec % 3600) / 60 ))
        eta_str="~${eta_h}h ${eta_m}m"
    else
        eta_str="(calculating)"
    fi

    # progress percent
    pct=$(awk -v h="$height" -v t="$TARGET" 'BEGIN{printf "%.2f", h/t*100}')

    echo "================================================="
    echo "  Blazecoin V1.5 sync monitor    $(date '+%H:%M:%S')"
    echo "================================================="
    echo "  Height       : $height / ~$TARGET"
    echo "  Progress     : $pct %"
    echo "  Connections  : $conns"
    echo "  Rate         : $rate blocks/sec"
    echo "  ETA to tip   : $eta_str"
    echo "================================================="
    echo "  Last 5 connected blocks:"
    grep "SetBestChain" "$LOG" 2>/dev/null | tail -5 | awk '{
        for (i=1; i<=NF; i++) {
            if ($i ~ /^height=/) h=$i
            if ($i ~ /^date=/) d=$i" "$(i+1)
        }
        print "    " h "  " d
    }'
    echo "================================================="
    echo "  Refreshing every 10s.  Ctrl+C to exit."

    prev_height=$height
    prev_time=$now
    sleep 10
done
