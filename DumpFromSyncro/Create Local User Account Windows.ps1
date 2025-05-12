Import-Module $env:SyncroModule

# Function to create a Syncro ticket
#function Create-SyncroTicket {
#    param (
#        [string]$problem
#    )
#    # Replace this with the actual Syncro command to create a ticket
#    & Create-Syncro-Ticket -Subject "User Creation Script $problem" -IssueType "Other" -Status "New"
#}
#
# Check if the user already exists
#if (Get-LocalUser -Name $username -ErrorAction SilentlyContinue) {
#    Write-Output "User $username already exists."
#} else {
#    try {
#        # Create the local admin account
#        $passwordSecure = ConvertTo-SecureString $password -AsPlainText -Force
#        New-LocalUser -Name $username -Password $passwordSecure -FullName $username -Description "Local User Account" -PasswordNeverExpires $false -PasswordChangeOnNextLogon $true
#
#        #if ($isAdmin -eq $true){
#            # Add the account to the Administrators group
#        #    Add-LocalGroupMember -Group "Administrators" -Member $username
#        #}
#
#        Write-Output "User $username has been created"
#    } catch {
#        # If any command fails, create a Syncro ticket
#        Create-SyncroTicket -Problem "Failed to create user $username"
#    }
#}
#
#


# The default password for the new accounts
$passwordSecure = ConvertTo-SecureString $password -AsPlainText -Force

# Group new users are added to (default is Users)
$group = "Users"

# PowerShell array containing the users to be created
$users = @(
    # List users here to be created
        "$UserName"

)

# Creates a new users for each entry in the $users array
foreach ($user in $users) {
        Write-Output "Username: $user Password: $password"
        
        # Create and add user to Users group
        New-LocalUser -Name "$user" -Password $passwordSecure
        Add-LocalGroupMember -Group "$group" -Member "$user"
        
        # Set users password to be changed at next logon
        $expUser = [ADSI]"WinNT://localhost/$user,user"
        $expUser.passwordExpired = 1
        $expUser.setinfo()
        
        }