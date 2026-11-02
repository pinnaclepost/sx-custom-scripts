#!/bin/bash
# Install the delayed EuCon launcher for the current user. Run on the studio
# Mac as the login user (no sudo). It takes effect from the next login; it
# doesn't launch anything now.
set -euo pipefail

LABEL="com.pinnaclepost.sx-eucon-launch"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST_DIR="$HOME/Library/Application Support/sx-custom-scripts"
SCRIPT="$DEST_DIR/sx-eucon-launch.sh"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/sx-eucon-launch.log"

mkdir -p "$DEST_DIR" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
install -m 755 "$SRC_DIR/sx-eucon-launch.sh" "$SCRIPT"
sed -e "s|__SCRIPT_PATH__|$SCRIPT|" -e "s|__LOG_PATH__|$LOG|" \
    "$SRC_DIR/$LABEL.plist" > "$PLIST"
plutil -lint "$PLIST"

echo "Installed $PLIST"
echo "It runs at next login. Turn off 'launch at login' in WSControl so it doesn't start early."
echo "Log: $LOG"
