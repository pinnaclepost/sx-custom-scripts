#!/bin/bash
# Launch WSControl and DADman at login only once the EuCon network is ready.
#
# WSControl's own autolaunch opens it straight away at login. If the EuCon
# NIC or the S6 MTM isn't up yet it fails to reach the BootManager once and
# never retries, and DADman then can't connect either. This waits for the
# EuCon address, then for the MTRX to answer, settles, and launches the apps
# in order. Written in bash (not Python) because the studio Macs have no
# Command Line Tools, and /usr/bin/python3 is only an installer stub there.
#
# Settings come from the LaunchAgent's EnvironmentVariables; defaults below.

EUCON_SUBNET="${EUCON_SUBNET:-192.168.50.}"   # prefix of the EuCon network
MTRX_HOST="${MTRX_HOST:-192.168.50.43}"       # MTRX control (DADman) host
MTRX_PORT="${MTRX_PORT:-10003}"               # MTRX control port
SETTLE_SECS="${SETTLE_SECS:-30}"              # extra wait for the MTM to boot
APP_GAP_SECS="${APP_GAP_SECS:-15}"            # gap between launching apps
TIMEOUT_SECS="${TIMEOUT_SECS:-180}"           # give up waiting and launch anyway
APPS="${APPS:-WSControlApp DADman}"           # launched in this order

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*"; }

has_eucon_address() {
    ifconfig | grep -qF "inet ${EUCON_SUBNET}"
}

mtrx_answers() {
    nc -z -G 2 "$MTRX_HOST" "$MTRX_PORT" >/dev/null 2>&1
}

# Wait for a check to pass, but never past the overall deadline.
wait_for() {
    local desc="$1" check="$2"
    while ! "$check"; do
        if (( SECONDS >= TIMEOUT_SECS )); then
            log "Timed out after ${SECONDS}s waiting for ${desc}; launching anyway"
            return 1
        fi
        sleep 2
    done
    log "${desc} ready after ${SECONDS}s"
}

log "Starting (subnet ${EUCON_SUBNET}x, MTRX ${MTRX_HOST}:${MTRX_PORT})"

if wait_for "EuCon address" has_eucon_address && wait_for "MTRX" mtrx_answers; then
    log "Settling ${SETTLE_SECS}s for the MTM"
    sleep "$SETTLE_SECS"
fi

first=1
for app in $APPS; do
    if pgrep -x "$app" >/dev/null; then
        log "${app} already running; leaving it"
        continue
    fi
    (( first )) || sleep "$APP_GAP_SECS"
    first=0
    if open -a "$app"; then
        log "Launched ${app}"
    else
        log "Failed to launch ${app}"
    fi
done
