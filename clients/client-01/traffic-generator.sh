#!/bin/bash

LOG="/opt/lab-client/logs/traffic.log"

while true; do

    echo "===== $(date -Is) =====" >> "$LOG"

    # Default gateway
    ping -c 1 -W 2 10.0.10.1 >> "$LOG" 2>&1

    # DNS
    dig +short google.com >> "$LOG" 2>&1

    # Internet HTTPS
    curl -sS \
        --max-time 10 \
        -o /dev/null \
        -w "Internet HTTPS: HTTP=%{http_code} time=%{time_total}s\n" \
        https://www.google.com >> "$LOG" 2>&1

    # VLAN 20 application
    curl -sS \
        --max-time 5 \
        -o /dev/null \
        -w "VLAN20 APP: HTTP=%{http_code} time=%{time_total}s\n" \
        http://10.0.20.50 >> "$LOG" 2>&1

    sleep 30

done

