#!/usr/bin/env bash
# bench-rpc-batch.sh — JSON-RPC batched throughput benchmark.
# Sends N calls in ONE HTTP request to measure server-side throughput
# without curl spawn / TCP handshake overhead dominating.

N=${1:-1000}

V15_URL="http://blazecoin_v15_user:7e4b9e243bd6b2965c8b31a2cd1f40dc@127.0.0.1:55415/"
STOCK_URL="http://test_peer_user:c522a0cb19e1068074bb92dfc12f5bf8@127.0.0.1:55421/"
HASH_AT_2M="4ceca77d22d672d391670224ca2f9457209bc1ecf5f5eaf5e9d652b81656995b"

bench_batch() {
    local label="$1"
    local url="$2"
    local method="$3"
    local params="$4"

    local payload_file=$(mktemp)
    {
        printf '['
        for i in $(seq 1 $N); do
            printf '{"jsonrpc":"1.0","id":%d,"method":"%s","params":%s}' "$i" "$method" "$params"
            [ "$i" -lt "$N" ] && printf ','
        done
        printf ']'
    } > "$payload_file"

    # Three runs, report best
    local best=999999
    for run in 1 2 3; do
        local start=$(date +%s.%N)
        curl -s -H 'Content-Type: application/json' --data-binary "@$payload_file" "$url" > /dev/null
        local end=$(date +%s.%N)
        local elapsed_ms=$(awk "BEGIN{printf \"%.1f\", ($end-$start)*1000}")
        if (( $(awk "BEGIN{print ($elapsed_ms<$best)}") )); then best=$elapsed_ms; fi
    done
    rm -f "$payload_file"

    local per_call_us=$(awk "BEGIN{printf \"%.1f\", $best*1000/$N}")
    local ops_per_sec=$(awk "BEGIN{printf \"%.0f\", $N*1000/$best}")
    printf "  %-25s  best=%5s ms  per-call=%6s us  %6s ops/sec\n" \
           "$label" "$best" "$per_call_us" "$ops_per_sec"
}

echo "Batched: $N calls per HTTP request, best of 3 runs"
echo ""

for op in "getblockcount:[]" "getblockhash:[1000000]" "getblock:[\"$HASH_AT_2M\"]"; do
    method="${op%%:*}"
    params="${op#*:}"
    echo "[$method $params]"
    bench_batch "V1.5 (MSVC 2022)"   "$V15_URL"   "$method" "$params"
    bench_batch "Stock 0.8.6.2 (2019)" "$STOCK_URL" "$method" "$params"
    echo ""
done
