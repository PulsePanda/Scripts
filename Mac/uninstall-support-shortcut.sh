#!/bin/bash
#
# Umbrella Systems — Desktop Support Shortcut Uninstaller
# Removes the "Submit a Ticket" shortcut from all users' desktops.
# Run as root via ScreenConnect.
#

INSTALL_DIR="/Library/UmbrellaSystems"
AGENT_LABEL="com.umbrellasystems.desktop-shortcut"
AGENT_PLIST="/Library/LaunchAgents/${AGENT_LABEL}.plist"
WEBLOC_NAME="Submit a Ticket.webloc"

echo "[Umbrella] Removing support shortcut..."

# Unload agent for all logged-in users
for USER_HOME in /Users/*/; do
    USERNAME=$(basename "$USER_HOME")
    [ "$USERNAME" = "Shared" ] && continue
    USER_UID=$(id -u "$USERNAME" 2>/dev/null) || continue
    launchctl bootout "gui/${USER_UID}/${AGENT_LABEL}" 2>/dev/null || true
    rm -f "${USER_HOME}Desktop/${WEBLOC_NAME}"
done

# Remove installed files
rm -f "$AGENT_PLIST"
rm -rf "$INSTALL_DIR"

echo "[Umbrella] Done. Shortcut removed."
