#!/bin/bash

CONFIG="/opt/lab-client/client.conf"
LOG="/opt/lab-client/logs/traffic.log"

if [[ ! -f "$CONFIG" ]]; then
    echo "Missing configuration: $CONFIG"
    exit 1
fi

source "$CONFIG"

iteration=0

while true; do

    iteration=$((iteration + 1))

    echo "===== $(date -Is) client=$CLIENT_NAME profile=$PROFILE =====" >> "$LOG"

    # 1. Gateway reachability
    ping -c 1 -W 2 "$GATEWAY" >> "$LOG" 2>&1

    # 2. DNS
    dig +short "$DNS_TEST" >> "$LOG" 2>&1

    # 3. VLAN 20 Nginx - every cycle
    curl -sS \
        --max-time 5 \
        -o /dev/null \
        -w "VLAN20 Nginx: HTTP=%{http_code} time=%{time_total}s\n" \
        "$VLAN20_URL" >> "$LOG" 2>&1

    # 4. FastAPI health - every cycle
    curl -sS \
        --max-time 5 \
        -o /dev/null \
        -w "API Health: HTTP=%{http_code} time=%{time_total}s\n" \
        "$API_HEALTH_URL" >> "$LOG" 2>&1

    # 5. FastAPI status - every second cycle
    if (( iteration % 2 == 0 )); then
        curl -sS \
            --max-time 5 \
            -o /dev/null \
            -w "API Status: HTTP=%{http_code} time=%{time_total}s\n" \
            "$API_STATUS_URL" >> "$LOG" 2>&1
    fi

    # 6. Internet HTTPS - every third cycle
    if (( iteration % 3 == 0 )); then
        curl -sS \
            --max-time 10 \
            -o /dev/null \
            -w "Internet HTTPS: HTTP=%{http_code} time=%{time_total}s\n" \
            "$INTERNET_URL" >> "$LOG" 2>&1
    fi

    # 7.Small file download - every 15th cycle (~5 minutes)
    if (( iteration % 15 == 0 )); then
        curl -sS \
            --max-time 30 \
            -o /dev/null \
            -w "File Download: HTTP=%{http_code} size=%{size_download} time=%{time_total}s speed=%{speed_download}B/s\n" \
            "$FILE_URL" >> "$LOG" 2>&1
    fi

    sleep "$INTERVAL"

done
