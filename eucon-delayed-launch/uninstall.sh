#!/bin/bash
# Remove the delayed EuCon launcher for the current user.
set -uo pipefail

LABEL="com.pinnaclepost.sx-eucon-launch"

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null
rm -f "$HOME/Library/LaunchAgents/$LABEL.plist" \
      "$HOME/Library/Application Support/sx-custom-scripts/sx-eucon-launch.sh"

echo "Removed $LABEL. Turn WSControl's 'launch at login' back on if you want the old behaviour."
