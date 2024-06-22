#!/bin/bash

# Define the username and password
USERNAME="localadmin"
PASSWORD="Sejong local admin 1!1"

# Create the local admin account
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

echo "Local administrator account '$USERNAME' created successfully."

