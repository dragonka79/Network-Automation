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

while true; do
    echo "===== $(date -Is) client=$CLIENT_NAME profile=$PROFILE =====" >> "$LOG"

    # Gateway connectivity
    if ping -c 1 -W 2 "$GATEWAY" >> "$LOG" 2>&1; then
        logger -t lab-client \
            "client=$CLIENT_NAME event=gateway_ping status=ok target=$GATEWAY"
    else
        logger -t lab-client \
            "client=$CLIENT_NAME event=gateway_ping status=failed target=$GATEWAY"
    fi

    # DNS
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
            "client=$CLIENT_NAME event=dns_lookup status=failed target=$DNS_TEST"
    fi

    # Internet HTTPS
    INTERNET_RESULT=$(curl -sS \
        --max-time 10 \
        -o /dev/null \
        -w "%{http_code} %{time_total}" \
        "$INTERNET_URL" 2>> "$LOG")
    CURL_RC=$?

    if [[ $CURL_RC -eq 0 ]]; then
        read -r HTTP_CODE RESPONSE_TIME <<< "$INTERNET_RESULT"

        echo "Internet HTTPS: HTTP=${HTTP_CODE} time=${RESPONSE_TIME}s" >> "$LOG"

        if [[ "$HTTP_CODE" =~ ^2 ]]; then
            STATUS="ok"
        else
            STATUS="failed"
        fi

        logger -t lab-client \
            "client=$CLIENT_NAME event=internet_https status=$STATUS http=$HTTP_CODE response_time=$RESPONSE_TIME"
    else
        echo "Internet HTTPS: curl_failed exit=$CURL_RC" >> "$LOG"

        logger -t lab-client \
            "client=$CLIENT_NAME event=internet_https status=failed curl_exit=$CURL_RC"
    fi

    # VLAN 20 application
    APP_RESULT=$(curl -sS \
        --max-time 5 \
        -o /dev/null \
        -w "%{http_code} %{time_total}" \
        "$VLAN20_URL" 2>> "$LOG")
    CURL_RC=$?

    if [[ $CURL_RC -eq 0 ]]; then
        read -r HTTP_CODE RESPONSE_TIME <<< "$APP_RESULT"

        echo "VLAN20 APP: HTTP=${HTTP_CODE} time=${RESPONSE_TIME}s" >> "$LOG"

        if [[ "$HTTP_CODE" =~ ^2 ]]; then
            STATUS="ok"
        else
            STATUS="failed"
        fi

        logger -t lab-client \
            "client=$CLIENT_NAME event=vlan20_app status=$STATUS http=$HTTP_CODE response_time=$RESPONSE_TIME"
    else
        echo "VLAN20 APP: curl_failed exit=$CURL_RC" >> "$LOG"

        logger -t lab-client \
            "client=$CLIENT_NAME event=vlan20_app status=failed curl_exit=$CURL_RC"
    fi

    # VLAN 20 FastAPI health check
    API_RESULT=$(curl -sS \
        --max-time 5 \
        -o /dev/null \
        -w "%{http_code} %{time_total}" \
        "$API_HEALTH_URL" 2>> "$LOG")
    CURL_RC=$?

    if [[ $CURL_RC -eq 0 ]]; then
        read -r HTTP_CODE RESPONSE_TIME <<< "$API_RESULT"

        echo "VLAN20 API Health: HTTP=${HTTP_CODE} time=${RESPONSE_TIME}s" >> "$LOG"

        if [[ "$HTTP_CODE" =~ ^2 ]]; then
            STATUS="ok"
        else
            STATUS="failed"
        fi

        logger -t lab-client \
            "client=$CLIENT_NAME event=api_health status=$STATUS http=$HTTP_CODE response_time=$RESPONSE_TIME"
    else
        echo "VLAN20 API Health: curl_failed exit=$CURL_RC" >> "$LOG"

        logger -t lab-client \
            "client=$CLIENT_NAME event=api_health status=failed curl_exit=$CURL_RC"
    fi

    sleep "$INTERVAL"
done

