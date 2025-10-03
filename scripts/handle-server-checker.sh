#!/bin/bash
START_COMMAND="/opt/dspace/bin/start-handle-server"

SEARCH_TERM="handle-server"

LOG_FILE="/opt/dspace/log/handle-server-monitor.log"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

SCRIPT_NAME=$(basename "$0")

# DEBUG
#ps aux | grep "$SEARCH_TERM" | grep -v -E "grep|check_handle_server.sh"
#ps aux | grep "$SEARCH_TERM" | grep -v -E "grep|check_handle_server.sh" | wc -l | tr -d '[:space:]'

# Získání počtu běžících procesů (ořezání výstupu + fallback na 0)
PROCESS_COUNT=$(ps aux | grep "$SEARCH_TERM" | grep -v -E "grep|$SCRIPT_NAME" | wc -l | tr -d '[:space:]')
PROCESS_COUNT=${PROCESS_COUNT:-0}  # fallback na 0, pokud je proměnná prázdná


# send to STDOUT and to LOG_FILE if the directory exists
log() {
    echo "$1"
    if [ -d "$LOG_DIR" ]; then
        echo "$1" >> "$LOG_FILE"
    fi
}

log "PROCESS COUNT: $PROCESS_COUNT"

# Check if number of running processes with given name is 0
if [ "$PROCESS_COUNT" -eq 0 ]; then
    # Print on STDOUT
    log "$TIMESTAMP: Process '$SEARCH_TERM' is not running. Starting..."
    # START
    START_OUTPUT=$($START_COMMAND 2>&1)
    # Print on STDOUT and append to log file
    log "$START_OUTPUT"
    log "$TIMESTAMP: Process started."
else
    # COMMAND is running, print to STDOUT and append to LOG_FILE
    log "$TIMESTAMP: Process '$SEARCH_TERM' is running."
fi