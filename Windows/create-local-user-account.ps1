#!ps

# Creates local user accounts, requires a password change at next logon,
# and turns off machine-wide password expiry so passwords never expire.

# !!!SET USERS!!! - one name per line
$users = @(
    "newuser"
)

# !!!SET PASSWORD!!!
$password = "changeme"

$group = "Users"
$adminAccount = "localadmin"

$passwordSecure = ConvertTo-SecureString $password -AsPlainText -Force

foreach ($user in $users) {

    # Guard: never create or touch the admin account here
    if ($user -eq $adminAccount) {
        Write-Output "Refusing to run against the '$adminAccount' account. Skipping."
        continue
    }

    # Don't clobber an existing account
    if (Get-LocalUser -Name $user -ErrorAction SilentlyContinue) {
        Write-Output "User '$user' already exists. Skipping - use the reset script instead."
        continue
    }

    try {
        New-LocalUser -Name $user -Password $passwordSecure -PasswordNeverExpires:$false -ErrorAction Stop
        Add-LocalGroupMember -Group $group -Member $user -ErrorAction Stop

        # Require a password change at next logon
        $expUser = [ADSI]"WinNT://localhost/$user,user"
        $expUser.passwordExpired = 1
        $expUser.SetInfo()

        Write-Output "Username: $user  Password: $password"
        Write-Output "User created and added to '$group'. Password must be changed at next logon."

    } catch {
        Write-Output "Failed to create user '$user'. Error: $_"
        continue
    }
}

# Turn off machine-wide password expiry (replaces the old 180-day policy)
net accounts /maxpwage:unlimited | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Output "Password expiry turned off for all local accounts."
} else {
    Write-Output "WARNING: 'net accounts' returned exit code $LASTEXITCODE. Password expiry may still be on."
}

# Show the resulting state
Get-LocalUser | Where-Object Enabled |
    Select-Object Name, PasswordLastSet, PasswordExpires |
    Format-Table -AutoSize | Out-String | Write-Output

Write-Output "Script execution completed."
