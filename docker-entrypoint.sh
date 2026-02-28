#!/bin/bash
set -e

# EBOKS_MODE: "pop3" (default) or "auth"
MODE="${EBOKS_MODE:-pop3}"

# POP3 server settings
POP3_PORT="${EBOKS_POP3_PORT:-8110}"
POP3_ADDR="${EBOKS_POP3_ADDR:-0.0.0.0}"

# Debug flag
DEBUG_FLAG=""
if [ "${EBOKS_DEBUG:-0}" = "1" ]; then
    DEBUG_FLAG="--debug"
fi

case "$MODE" in
    pop3)
        echo "Starting Net::Eboks POP3 proxy on ${POP3_ADDR}:${POP3_PORT}..."
        echo "Connect your mail client to this host on port ${POP3_PORT}."
        echo "Username: your CPR number (e.g. 123456-7890)"
        echo "Password: your e-Boks mobile password"
        exec eboks2pop --port "$POP3_PORT" --addr "$POP3_ADDR" $DEBUG_FLAG
        ;;
    auth)
        echo "Starting Net::Eboks MitID authentication wizard..."
        echo ""
        echo "IMPORTANT: This mode requires host networking (--network host) or"
        echo "           a browser running inside the container/same host."
        echo ""
        echo "Open a browser with CORS disabled and go to: http://localhost:9999/"
        echo ""
        echo "  Chrome example:"
        echo "    mkdir /tmp/chrome && chrome --disable-web-security --user-data-dir=/tmp/chrome"
        echo ""
        exec eboks-auth-mitid
        ;;
    *)
        echo "Unknown EBOKS_MODE: '$MODE'. Valid modes: pop3, auth"
        exit 1
        ;;
esac
