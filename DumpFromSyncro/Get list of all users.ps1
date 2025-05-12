# Get all local user accounts
$localUsers = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount=True"

# Print header
Write-Output "Local User Accounts:"
Write-Output "====================="

# Loop through each user and print their details
foreach ($user in $localUsers) {
    Write-Output "Username: $($user.Name)"
    Write-Output "Account Type: $($user.AccountType)"
    Write-Output "Status: $($user.Status)"
    Write-Output "====================="
}

# End of script
Write-Output "End of Local User Accounts List"
