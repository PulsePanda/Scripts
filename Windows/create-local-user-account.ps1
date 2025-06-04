#!ps

# this script creates a local user account, and requires the password to be changed at the next logon.

# !!!SET USERNAME!!!
$UserName = "newuser"
# !!!SET PASSWORD!!!
$password = "changeme"

# The default password for the new accounts
$passwordSecure = ConvertTo-SecureString $password -AsPlainText -Force

# Group new users are added to (default is Users)
$group = "Users"

# PowerShell array containing the users to be created
$users = @(
    # List users here to be created
    "$UserName"
)

# Creates a new user for each entry in the $users array
foreach ($user in $users) {
    Write-Output "Username: $user Password: $password"

    # Create and add user to Users group
    New-LocalUser -Name "$user" -Password $passwordSecure
    Add-LocalGroupMember -Group "$group" -Member "$user"

    # Set user's password to be changed at next logon
    $expUser = [ADSI]"WinNT://localhost/$user,user"
    $expUser.passwordExpired = 1
    $expUser.setinfo()
    Write-Output "User created. Password must be changed at next logon."
}