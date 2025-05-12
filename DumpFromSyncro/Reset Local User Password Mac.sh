#!/bin/bash

# Set the user's password
echo "$username:$password" | dscl . -passwd /Users/$username

# Set the user to change the password at next login
pwpolicy -u $username -setpolicy "newPasswordRequired=1"

# Output success message
echo "Password for user '$username' has been set and will be required to change on next login."

exit 0