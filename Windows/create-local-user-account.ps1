#!ps

# Creates local user accounts, requires a password change at next logon,
# and enforces a machine-wide 180-day password expiry with localadmin exempt.

# !!!SET USERS!!! - one name per line
$users = @(
    "SarahSchlake"
)

# !!!SET PASSWORD!!!
$password = "changeme"

$group = "Users"
$adminAccount = "localadmin"
$maxPasswordAge = 180

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

# Exempt the admin account BEFORE the machine policy applies
$admin = Get-LocalUser -Name $adminAccount -ErrorAction SilentlyContinue
if ($null -eq $admin) {
    Write-Output "WARNING: '$adminAccount' not found. Skipping password policy - would have applied to all local accounts."
    return
}

try {
    Set-LocalUser -Name $adminAccount -PasswordNeverExpires $true
    Write-Output "'$adminAccount' is exempt from password expiry."
} catch {
    Write-Output "Failed to exempt '$adminAccount'. Error: $_"
    Write-Output "Skipping password policy - not applying it while '$adminAccount' is unprotected."
    return
}

# Apply the machine-wide policy
net accounts /maxpwage:$maxPasswordAge | Out-Null
net accounts /minpwage:0 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Output "Password expiry set to $maxPasswordAge days for all local accounts except '$adminAccount'."
} else {
    Write-Output "WARNING: 'net accounts' returned exit code $LASTEXITCODE. Password policy may not be set."
}

# Show the resulting state
Get-LocalUser | Where-Object Enabled |
    Select-Object Name, PasswordLastSet, PasswordNeverExpires |
    Format-Table -AutoSize | Out-String | Write-Output

Write-Output "Script execution completed."
