$passwordSecure = ConvertTo-SecureString $password -AsPlainText -Force
$UserAccount = Get-LocalUser -Name "localadmin"
$UserAccount | Set-LocalUser -Password $passwordSecure -PasswordNeverExpires $true