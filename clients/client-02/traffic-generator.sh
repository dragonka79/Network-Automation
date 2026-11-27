#!/bin/bash

# Local logs are sent to LOG.
# Log entries of modified format is also handled by rsyslog, the detailed ping output, resolved IP addresses, etc. remain only in traffic.log.


CONFIG="/opt/lab-client/client.conf"
LOG="/opt/lab-client/logs/traffic.log"

if [[ ! -f "$CONFIG" ]]; then
    echo "Missing configuration: $CONFIG"
    exit 1
fi

source "$CONFIG"

log_http_event() {
    local label="$1"
    local event="$2"
    local url="$3"
    local max_time="$4"

    local result
    local curl_rc
    local http_code
    local response_time
    local status

    result=$(curl -sS \
        --max-time "$max_time" \
        -o /dev/null \
        -w "%{http_code} %{time_total}" \
        "$url" 2>> "$LOG")
    curl_rc=$?

    if [[ $curl_rc -eq 0 ]]; then
        read -r http_code response_time <<< "$result"

        echo "${label}: HTTP=${http_code} time=${response_time}s" >> "$LOG"

        if [[ "$http_code" =~ ^2 ]]; then
            status="ok"
        else
            status="failed"
        fi

        logger -t lab-client \
            "client=$CLIENT_NAME event=$event status=$status http=$http_code response_time=$response_time"
    else
        echo "${label}: curl_failed exit=${curl_rc}" >> "$LOG"

        logger -t lab-client \
            "client=$CLIENT_NAME event=$event status=failed curl_exit=$curl_rc"
    fi
}

iteration=0

while true; do
    iteration=$((iteration + 1))

    echo "===== $(date -Is) client=$CLIENT_NAME profile=$PROFILE iteration=$iteration =====" >> "$LOG"

    # 1. Gateway reachability - every cycle
    if ping -c 1 -W 2 "$GATEWAY" >> "$LOG" 2>&1; then
        logger -t lab-client \
            "client=$CLIENT_NAME event=gateway_ping status=ok target=$GATEWAY"
    else
        logger -t lab-client \
            "client=$CLIENT_NAME event=gateway_ping status=failed target=$GATEWAY"
    fi

    # 2. DNS lookup - every cycle
    DNS_RESULT=$(dig +short "$DNS_TEST" 2>> "$LOG")
    DIG_RC=$?

    if [[ -n "$DNS_RESULT" ]]; then
        printf '%s\n' "$DNS_RESULT" >> "$LOG"
    fi

    if [[ $DIG_RC -eq 0 && -n "$DNS_RESULT" ]]; then
        logger -t lab-client \
            "client=$CLIENT_NAME event=dns_lookup status=ok target=$DNS_TEST"
    else
        logger -t lab-client \
            "client=$CLIENT_NAME event=dns_lookup status=failed target=$DNS_TEST dig_exit=$DIG_RC"
    fi

    # 3. VLAN 20 Nginx - every cycle
    log_http_event \
        "VLAN20 Nginx" \
        "vlan20_nginx" \
        "$VLAN20_URL" \
        "5"

    # 4. FastAPI health - every cycle
    log_http_event \
        "API Health" \
        "api_health" \
        "$API_HEALTH_URL" \
        "5"

    # 5. FastAPI status - every second cycle
    if (( iteration % 2 == 0 )); then
        log_http_event \
            "API Status" \
            "api_status" \
            "$API_STATUS_URL" \
            "5"
    fi

    # 6. Internet HTTPS - every third cycle
    if (( iteration % 3 == 0 )); then
        log_http_event \
            "Internet HTTPS" \
            "internet_https" \
            "$INTERNET_URL" \
            "10"
    fi

    # 7. Small file download - every 15th cycle
    if (( iteration % 15 == 0 )); then
        FILE_RESULT=$(curl -sS \
            --max-time 30 \
            -o /dev/null \
            -w "%{http_code} %{size_download} %{time_total} %{speed_download}" \
            "$FILE_URL" 2>> "$LOG")
        CURL_RC=$?

        if [[ $CURL_RC -eq 0 ]]; then
            read -r HTTP_CODE SIZE_DOWNLOAD RESPONSE_TIME DOWNLOAD_SPEED <<< "$FILE_RESULT"

            echo "File Download: HTTP=${HTTP_CODE} size=${SIZE_DOWNLOAD} time=${RESPONSE_TIME}s speed=${DOWNLOAD_SPEED}B/s" >> "$LOG"

            if [[ "$HTTP_CODE" =~ ^2 ]]; then
                STATUS="ok"
            else
                STATUS="failed"
            fi

            logger -t lab-client \
                "client=$CLIENT_NAME event=file_download status=$STATUS http=$HTTP_CODE bytes=$SIZE_DOWNLOAD response_time=$RESPONSE_TIME speed_bps=$DOWNLOAD_SPEED"
        else
            echo "File Download: curl_failed exit=${CURL_RC}" >> "$LOG"

            logger -t lab-client \
                "client=$CLIENT_NAME event=file_download status=failed curl_exit=$CURL_RC"
        fi
    fi

    # 8. SSH session - every 15th cycle
    if (( iteration % 15 == 0 )); then
        if ssh \
            -i "$SSH_KEY" \
            -o BatchMode=yes \
            -o ConnectTimeout=5 \
            "$SSH_USER@$SSH_HOST" \
            "hostname && uptime" >> "$LOG" 2>&1; then

            logger -t lab-client \
                "client=$CLIENT_NAME event=ssh_session status=ok target=$SSH_HOST user=$SSH_USER"
        else
            SSH_RC=$?

            logger -t lab-client \
                "client=$CLIENT_NAME event=ssh_session status=failed target=$SSH_HOST user=$SSH_USER ssh_exit=$SSH_RC"
        fi
    fi

    # 9. Controlled UDP traffic burst - every 30th cycle
    if (( iteration % 30 == 0 )); then
        echo "Controlled Traffic Burst: START bandwidth=$IPERF_BANDWIDTH duration=${IPERF_DURATION}s" >> "$LOG"

        logger -t lab-client \
            "client=$CLIENT_NAME event=traffic_burst phase=start target=$IPERF_SERVER protocol=udp bandwidth=$IPERF_BANDWIDTH duration=$IPERF_DURATION"

        if iperf3 \
            -c "$IPERF_SERVER" \
            -u \
            -b "$IPERF_BANDWIDTH" \
            -t "$IPERF_DURATION" >> "$LOG" 2>&1; then

            echo "Controlled Traffic Burst: END status=ok" >> "$LOG"

            logger -t lab-client \
                "client=$CLIENT_NAME event=traffic_burst phase=end status=ok target=$IPERF_SERVER protocol=udp bandwidth=$IPERF_BANDWIDTH duration=$IPERF_DURATION"
        else
            IPERF_RC=$?

            echo "Controlled Traffic Burst: END status=failed exit=$IPERF_RC" >> "$LOG"

            logger -t lab-client \
                "client=$CLIENT_NAME event=traffic_burst phase=end status=failed target=$IPERF_SERVER protocol=udp iperf_exit=$IPERF_RC"
        fi
    fi

    sleep "$INTERVAL"
done
