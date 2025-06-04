#!ps

# this script resets the password of a local user account, and requires the password to be changed at the next logon.
# Do not use this script to reset the localadmin account password

$username = "newuser"  # !!!SET USERNAME!!!
$password = "changeme"  # !!!SET PASSWORD!!!

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
    
    # Set user's password to be changed at next logon
    $expUser = [ADSI]"WinNT://localhost/$user,user"
    $expUser.passwordExpired = 1
    $expUser.setinfo()
    
    Write-Output "Password for user account '$username' has been reset successfully."
    Write-Output "Username: $user Password: $password"
    Write-Output "Password must be changed at next logon."
    
} catch {
    Write-Output "Failed to reset the password. Error: $_"
}
