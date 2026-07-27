#!ps

# Resets the password of a local user account and requires a change at next logon.
# Also enforces a machine-wide 180-day password expiry, with localadmin exempt.
# Intended for newly added user accounts.

# !!!SET USERNAME!!!
$username = "test"
# !!!SET PASSWORD!!!
$password = "changeme"

$adminAccount = "localadmin"
$maxPasswordAge = 180

# Guard: never target the admin account with this script
if ($username -eq $adminAccount) {
    Write-Output "Refusing to run against the '$adminAccount' account."
    return
}

# Check if the user account exists
$user = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
if ($null -eq $user) {
    Write-Output "User account '$username' does not exist."
    return
}

try {
    # Reset the password
    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
    Set-LocalUser -Name $username -Password $securePassword -PasswordNeverExpires $false

    # Require a password change at next logon
    $expUser = [ADSI]"WinNT://localhost/$username,user"
    $expUser.passwordExpired = 1
    $expUser.SetInfo()

    Write-Output "Password for user account '$username' has been reset successfully."
    Write-Output "Username: $username  Password: $password"
    Write-Output "Password must be changed at next logon."

} catch {
    Write-Output "Failed to reset the password. Error: $_"
    return
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
