#!ps

# This script deletes a specific user account

# Define the account name to be deleted
$accountToDelete = ""

# Attempt to delete the specified account
if ($accountToDelete) {
    try {
        Write-Host "Attempting to delete user account: $accountToDelete"
        Remove-LocalUser -Name $accountToDelete -ErrorAction Stop
        Write-Host "Successfully deleted user account: $accountToDelete"
    } catch {
        Write-Host "Failed to delete user account: $accountToDelete. Error: $_"
    }
} else {
    Write-Host "Error: accountToDelete variable is not set or is empty"
}

Write-Host "Script execution completed."