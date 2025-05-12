#!/bin/bash

# Get the list of local user accounts
users=$(dscl . list /Users | grep -v '^_')

echo "Local user accounts on this macOS system:"
echo "-----------------------------------------"

# Loop through each user and display their details
for user in $users; do
    user_info=$(dscl . read /Users/$user RealName UniqueID | grep -E "RealName:|UniqueID:")
    echo "$user_info"
    echo "-----------------------------------------"
done
