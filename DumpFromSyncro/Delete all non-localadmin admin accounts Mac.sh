#!/bin/bash

# Define the list of account names to be deleted
accountsToDelete=("admin" "Sejong Academy" "Sejong Admin" "Admin" "Administrator")

# Loop through each account name and attempt to delete the account
for account in "${accountsToDelete[@]}"; do
    # Check if the account exists
    if id "$account" &>/dev/null; then
        echo "Attempting to delete user account: $account"
        
        # Attempt to delete the account and capture any errors
        if dscl . -delete "/Users/$account" &>/dev/null; then
            echo "Successfully deleted user account: $account"
        else
            echo "Failed to delete user account: $account. Error: Unable to delete user account"
            #syncro create-syncro-ticket --subject="Local account deletion $account" --issue-type="Other" --status="New"
        fi
    else
        echo "User account: $account does not exist"
    fi
done

echo "Script execution completed."
