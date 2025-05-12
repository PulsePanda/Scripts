#!/bin/bash

# Define the username and password
USERNAME="localadmin"

# Function to create a Syncro ticket
create_syncro_ticket() {
    local problem="$1"
    syncro create-syncro-ticket --subject="localadmin Script $problem" --issue-type="Other" --status="New"
}

# Check if the user already exists
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists."
else
    # Try to create the local admin account and handle any errors
    {
        sudo dscl . -create /Users/$USERNAME
        sudo dscl . -create /Users/$USERNAME UserShell /bin/bash
        sudo dscl . -create /Users/$USERNAME RealName "localadmin"
        sudo dscl . -create /Users/$USERNAME UniqueID "510"
        sudo dscl . -create /Users/$USERNAME PrimaryGroupID 80
        sudo dscl . -create /Users/$USERNAME NFSHomeDirectory /Users/$USERNAME

        # Set the password for the account
        sudo dscl . -passwd /Users/$USERNAME "$PASSWORD"

        # Add the account to the admin group
        sudo dscl . -append /Groups/admin GroupMembership $USERNAME

        # Create the home directory for the user
        sudo createhomedir -c -u $USERNAME > /dev/null
        echo "User $USERNAME has been created and added to the admin group."
    } || {
        # If any command fails, create a Syncro ticket
        create_syncro_ticket "Failed to create user $USERNAME"
    }
fi