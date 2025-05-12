#!/bin/bash

# Variables
HOMEDIR="/Users/$username"

# Create the user account
#sysadminctl -addUser "$username" -fullName "$username" -password "$password" -home "$HOMEDIR" -admin
sysadminctl -addUser "$username" -fullName "$username" -password "$password" -home "$HOMEDIR"

# Convert the account to a standard user (non-admin)
#dseditgroup -o edit -d "$username" -t user admin

# Set password to be changed on next login
#dscl . -create /Users/$username PasswordPolicyOptions 'policyCategoryAuthentication 0x1'
pwpolicy -u $username -setpolicy "newPasswordRequired=1"

# Verify account creation
if id "$username" &>/dev/null; then
    echo "User $username has been created successfully."
else
    echo "Failed to create user $username."
fi