#!ps

# This script resets the localadmin account password, and sets it to never expire.
# It is different from the reset-user-password script, use this one to reset the localadmin account password.

$password = "password"  # !!!SET PASSWORD!!!

$passwordSecure = ConvertTo-SecureString $password -AsPlainText -Force
$UserAccount = Get-LocalUser -Name "localadmin"
$UserAccount | Set-LocalUser -Password $passwordSecure -PasswordNeverExpires $true