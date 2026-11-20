#!/bin/bash

CONFIG="/opt/lab-client/client.conf"
LOG="/opt/lab-client/logs/traffic.log"

if [[ ! -f "$CONFIG" ]]; then
    echo "Missing configuration: $CONFIG"
    exit 1
fi

source "$CONFIG"

while true; do

    echo "===== $(date -Is) client=$CLIENT_NAME profile=$PROFILE =====" >> "$LOG"

    # Gateway connectivity
    ping -c 1 -W 2 "$GATEWAY" >> "$LOG" 2>&1

    # DNS
    dig +short "$DNS_TEST" >> "$LOG" 2>&1

    # Internet HTTPS
    curl -sS \
        --max-time 10 \
        -o /dev/null \
        -w "Internet HTTPS: HTTP=%{http_code} time=%{time_total}s\n" \
        "$INTERNET_URL" >> "$LOG" 2>&1

    # VLAN 20 application
    curl -sS \
        --max-time 5 \
        -o /dev/null \
        -w "VLAN20 APP: HTTP=%{http_code} time=%{time_total}s\n" \
        "$VLAN20_URL" >> "$LOG" 2>&1

    sleep "$INTERVAL"

    # VLAN 20 FastAPI health check
    curl -sS \
        --max-time 5 \
        -o /dev/null \
        -w "VLAN20 API Health: HTTP=%{http_code} time=%{time_total}s\n" \
        "$API_HEALTH_URL" >> "$LOG" 2>&1
done

