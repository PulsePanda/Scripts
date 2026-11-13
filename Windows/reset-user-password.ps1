#!ps

# Resets the password of a local user account and requires a change at next logon.
# Also turns off machine-wide password expiry so passwords never expire.

# !!!SET USERNAME!!!
$username = "test"
# !!!SET PASSWORD!!!
$password = "changeme"

$adminAccount = "localadmin"

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
    # Reset the password. PasswordNeverExpires stays false: Windows ignores
    # "change at next logon" for accounts flagged never-expire.
    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
    Set-LocalUser -Name $username -Password $securePassword -PasswordNeverExpires $false -ErrorAction Stop

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
