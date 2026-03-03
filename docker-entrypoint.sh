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
        AUTH_LISTEN="${EBOKS_AUTH_LISTEN:-0.0.0.0:9999}"
        export EBOKS_AUTH_LISTEN="$AUTH_LISTEN"
        echo "Starting Net::Eboks MitID authentication wizard..."
        echo ""
        echo "Open a browser and go to: http://<this-host>:9999/"
        echo "(Replace <this-host> with the hostname or IP of this machine)"
        echo ""
        exec eboks-auth-mitid
        ;;
    dump)
        DUMP_DIR="${EBOKS_DUMP_DIR:-/consume}"
        DUMP_INTERVAL="${EBOKS_DUMP_INTERVAL:-0}"
        if [ -z "${EBOKS_CPR:-}" ] || [ -z "${EBOKS_PASSWORD:-}" ]; then
            echo "ERROR: EBOKS_MODE=dump requires EBOKS_CPR and EBOKS_PASSWORD env vars."
            exit 1
        fi
        echo "Starting Net::Eboks Paperless-ngx dump mode..."
        echo "Output directory: ${DUMP_DIR}"
        if [ "${DUMP_INTERVAL}" = "0" ]; then
            echo "Running once (set EBOKS_DUMP_INTERVAL to poll periodically)."
        else
            echo "Polling every ${DUMP_INTERVAL} seconds."
        fi
        exec eboks2paperless --output "$DUMP_DIR" --interval "$DUMP_INTERVAL" $DEBUG_FLAG
        ;;
    *)
        echo "Unknown EBOKS_MODE: '$MODE'. Valid modes: pop3, auth, dump"
        exit 1
        ;;
esac
