Import-Module $env:SyncroModule

# Define the username and password
$username = "localadmin"

# Function to create a Syncro ticket
function Create-SyncroTicket {
    param (
        [string]$problem
    )
    # Replace this with the actual Syncro command to create a ticket
    & Create-Syncro-Ticket -Subject "localadmin Script $problem" -IssueType "Other" -Status "New"
}

# Check if the user already exists
if (Get-LocalUser -Name $username -ErrorAction SilentlyContinue) {
    Write-Output "User $username already exists."
} else {
    try {
        # Create the local admin account
        $passwordSecure = ConvertTo-SecureString $password -AsPlainText -Force
        New-LocalUser -Name $username -Password $passwordSecure -PasswordNeverExpires -FullName "localadmin" -Description "Local Administrator Account"

        # Add the account to the Administrators group
        Add-LocalGroupMember -Group "Administrators" -Member $username

        Write-Output "User $username has been created and added to the Administrators group."
    } catch {
        # If any command fails, create a Syncro ticket
        Create-SyncroTicket -Problem "Failed to create user $username"
    }
}
