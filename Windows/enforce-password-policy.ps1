#!ps #timeout=60000 #maxlength=100000

# This script enforces a minimum password length and sets a default password
# on any local accounts that currently have no password.

# !!!SET MINIMUM PASSWORD LENGTH!!!
$MinPasswordLength = 8
# !!!SET DEFAULT PASSWORD FOR ACCOUNTS WITHOUT ONE!!!
$DefaultPassword = "changeme"
# !!!SET ACCOUNTS TO SKIP!!!
$ExcludeAccounts = @("localadmin", "Administrator", "DefaultAccount", "WDAGUtilityAccount", "Guest")

# Step 1: Enforce minimum password length
Write-Host "Setting minimum password length to $MinPasswordLength..."
net accounts /minpwlen:$MinPasswordLength
Write-Host ""

# Step 2: Find accounts without passwords and set a default
Write-Host "Checking local accounts for blank passwords..."
$localUsers = Get-LocalUser | Where-Object { $_.Enabled -eq $true -and $_.Name -notin $ExcludeAccounts }
$fixedCount = 0

foreach ($user in $localUsers) {
    $userName = $user.Name
    try {
        # ChangePassword only succeeds if the old password matches
        # If the account has a blank password, old="" will work
        $adsiUser = [ADSI]"WinNT://localhost/$userName,user"
        $adsiUser.ChangePassword("", $DefaultPassword)
        # If we got here, the password WAS blank — now set to default
        $adsiUser.passwordExpired = 1
        $adsiUser.SetInfo()
        $fixedCount++
        Write-Host "FIXED: $userName -- default password set, must change at next logon"
    } catch {
        # ChangePassword failed = password was NOT blank (good)
        Write-Host "OK: $userName"
    }
}

Write-Host ""
Write-Host "Done. $fixedCount account(s) had blank passwords and were fixed."
Write-Host "Minimum password length is now $MinPasswordLength characters."
