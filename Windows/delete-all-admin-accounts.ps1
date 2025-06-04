#!ps

# This script deletes all admin accounts on a computer, except for localadmin and the built-in Administrator account.

# Get all local users who are members of the Administrators group
Write-Host "Identifying all local admin accounts..."
$adminGroup = Get-LocalGroup -Name "Administrators"
$adminAccounts = Get-LocalGroupMember -Group $adminGroup | Where-Object {$_.ObjectClass -eq "User"}

# Account to preserve
$preserveAccount = "localadmin"

Write-Host "Found the following admin accounts:"
$adminAccounts | ForEach-Object { Write-Host "- $($_.Name.Split('\')[1])" }

# Process each admin account
foreach ($account in $adminAccounts) {
    # Extract just the username portion from the Name (which includes domain\username)
    $username = $account.Name.Split('\')[1]
    
    # Skip the account we want to preserve
    if ($username -eq $preserveAccount) {
        Write-Host "Preserving account: $username as requested"
        continue
    }
    
    # Skip the built-in Administrator account (SID check is more reliable than name)
    $user = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
    if ($user -and $user.SID.Value.EndsWith("-500")) {
        Write-Host "Skipping built-in Administrator account: $username"
        continue
    }
    
    try {
        Write-Host "Attempting to delete admin account: $username"
        Remove-LocalUser -Name $username -ErrorAction Stop
        Write-Host "Successfully deleted admin account: $username" -ForegroundColor Green
    } 
    catch {
        $errorMessage = $_.Exception.Message
        Write-Host "Failed to delete admin account: $username. Error: $errorMessage" -ForegroundColor Red
        
        # Uncomment to create a ticket for failed deletions
        # Create-Syncro-Ticket -Subject "Failed to delete local admin account: $username" -IssueType "Other" -Status "New" -Description $errorMessage
    }
}

Write-Host "Script execution completed."