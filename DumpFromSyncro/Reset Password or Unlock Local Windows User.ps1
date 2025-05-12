Import-Module $env:SyncroModule -WarningAction SilentlyContinue

##########################################
## Reset Password Script####################


$users = Get-LocalUser | Where-Object { $_.Enabled -eq $true }

$userDetails = foreach ($user in $users) {
    $isAdmin = (Get-LocalGroupMember -Group "Administrators" -Member $user.Name -ErrorAction SilentlyContinue) -ne $null

    [PSCustomObject]@{
        Name = $user.Name
        LastLogon = $user.LastLogon
        IsAdministrator = $isAdmin
        PasswordLastSet = $user.PasswordLastSet
        PasswordExpires = $user.PasswordExpires
        IsLocked = $isLocked
    }
}



$lastuser = $userDetails | Sort-Object -Property LastLogon -Descending | Select-Object -First 1 | Select-Object -ExpandProperty Name


Write-Host "List Of currently Enabled users" -foregroundcolor "Red"

$userDetails | Format-Table -AutoSize
Write-Host "**********************************************************************" -foregroundcolor "Yellow"
Write-Host " "
Write-Host "Last Logged in user was " $lastuser




#####################
## RESET Password & ublock user
Write-Host " "

if ($action -eq "Reset_Password") 
{
    Write-Host "Resetting Password"
    Set-LocalUser -Name $Username -Password (ConvertTo-SecureString -String $NewPassword -AsPlainText -Force)
    Write-Host "Password for user $usernmae has been reset."
    
    ## WMIC USERACCOUNT WHERE "Name='$username'" SET PasswordExpires=FALSE
    Write-Host "Unlocking User after password reset"
    net user $username /active:yes
       
}

else
{
     Write-Host "Unlocking User only"
     net user $username /active:yes
}


### Logic to add to admin Group

if ($Add2AdminGRP -eq "Add") {
    Write-Host "Adding user to Admin Group"
    net localgroup administrators $username /add
}
elseif ($Add2AdminGRP -eq "Remove") {
    Write-Host "Removing user from Admin Group"
    net localgroup administrators $username /delete
}
else {
    Write-Host "User Group is unchanged"
    # Additional code for handling unchanged user group, if necessary
}




