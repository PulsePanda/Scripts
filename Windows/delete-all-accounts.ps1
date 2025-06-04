#!ps

# This script deletes all user accounts except for localadmin

# Define the account name to be excluded from deletion
$excludeAccount = "localadmin"

# Get a list of all local user accounts
$allUsers = Get-WmiObject -Class Win32_UserAccount | Where-Object { $_.LocalAccount -eq $true }

# Loop through each user account and delete if it does not match the excluded account
foreach ($user in $allUsers) {
    $userName = $user.Name
    if ($userName -ne $excludeAccount) {
        try {
            # Attempt to delete the account
            Write-Host "Attempting to delete user account: $userName"
            Remove-LocalUser -Name $userName -ErrorAction Stop
            Write-Host "Successfully deleted user account: $userName"
        } catch {
            Write-Host "Failed to delete user account: $userName. Error: $_"
        }
    } else {
        Write-Host "Skipping excluded user account: $userName"
    }
}

Write-Host "Script execution completed."
