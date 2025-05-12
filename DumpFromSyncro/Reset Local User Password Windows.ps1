# Check if the user account exists
$user = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
if ($null -eq $user) {
    Write-Output "User account '$username' does not exist."
    exit
}

# Reset the password
try {
    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
    $user | Set-LocalUser -Password $securePassword
    
    # Force the user to change password at next logon
    $user | Set-LocalUser -PasswordNeverExpires $false
    $user | Set-LocalUser -UserMayChangePassword $true

    # Use net user command to set the flag for password change at next logon
    net user $username /logonpasswordchg:yes
    
    Write-Output "Password for user account '$username' has been reset successfully."
    Write-Output "Username: $user Password: $password"
    
} catch {
    Write-Output "Failed to reset the password. Error: $_"
}
