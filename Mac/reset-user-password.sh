#!/bin/bash

# This script resets the password of a local user account and requires a change at next login.
# Runs as root (MDM). Mac counterpart of Windows/reset-user-password.ps1.

# !!!SET USERNAME!!!
username="test"
# !!!SET PASSWORD!!!
password="changeme"

# Optional: an admin account with a SecureToken. Needed to keep the FileVault
# unlock password in sync when the target user has a SecureToken. Leave blank to skip.
# !!!SET ADMIN USERNAME!!!
adminUser=""
# !!!SET ADMIN PASSWORD!!!
adminPassword=""

adminAccount="localadmin"

# Guard: must run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must run as root."
    exit 1
fi

# Guard: never target the admin account or root
if [ "$username" = "$adminAccount" ] || [ "$username" = "root" ]; then
    echo "Refusing to run against the '$username' account."
    exit 1
fi

# Check if the user account exists
if ! dscl . -read "/Users/$username" > /dev/null 2>&1; then
    echo "User account '$username' does not exist."
    exit 1
fi

# Guard: never target system or hidden service accounts
uid=$(dscl . -read "/Users/$username" UniqueID | awk '{print $2}')
if [ -z "$uid" ] || [ "$uid" -lt 500 ]; then
    echo "Refusing to run against '$username' (UID $uid is a system account)."
    exit 1
fi

# Check SecureToken status. Resetting without an admin's credentials leaves
# the FileVault unlock password and SecureToken on the old password.
tokenStatus=$(sysadminctl -secureTokenStatus "$username" 2>&1)
hasToken=false
if echo "$tokenStatus" | grep -q "ENABLED"; then
    hasToken=true
fi

# Reset the password
if [ "$hasToken" = true ] && [ -n "$adminUser" ] && [ -n "$adminPassword" ]; then
    echo "'$username' has a SecureToken. Resetting with admin '$adminUser' to keep FileVault in sync."
    sysadminctl -resetPasswordFor "$username" -newPassword "$password" \
        -adminUser "$adminUser" -adminPassword "$adminPassword" 2>&1
else
    if [ "$hasToken" = true ]; then
        echo "WARNING: '$username' has a SecureToken but no admin credentials were set."
        echo "WARNING: The login password will change, but the FileVault unlock password may stay the old one."
    fi
    dscl . -passwd "/Users/$username" "$password"
fi

# sysadminctl exits 0 even on failure, so verify the new password directly
if ! dscl . -authonly "$username" "$password" > /dev/null 2>&1; then
    echo "Failed to reset the password for '$username'. The new password does not authenticate."
    exit 1
fi

echo "Password for user account '$username' has been reset successfully."
echo "Username: $username  Password: $password"

# Require a password change at next login
if pwpolicy -u "$username" -setpolicy "newPasswordRequired=1" > /dev/null 2>&1; then
    echo "Password must be changed at next login."
else
    echo "WARNING: Could not set 'change password at next login' for '$username'."
fi

# The old login keychain stays locked with the old password.
echo "Note: at next login macOS will ask to update or create a new login keychain."

echo "Script execution completed."
