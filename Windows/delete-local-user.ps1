#!ps

# Deletes local user accounts, skipping anything in the Administrators group
# and the Windows built-in accounts.
# Runs in dry-run mode by default - set $DryRun = $false to actually delete.

$DryRun = $true

# Built-in accounts, protected by well-known RID (last part of the SID):
# 500 Administrator, 501 Guest, 503 DefaultAccount, 504 WDAGUtilityAccount
$protectedRids = @(500, 501, 503, 504)

# Enumerate the Administrators group. If this fails, delete nothing.
try {
    $adminSids = @((Get-LocalGroupMember -Group "Administrators" -ErrorAction Stop).SID.Value)
} catch {
    Write-Output "Could not read the Administrators group: $_"
    Write-Output "Aborting - not deleting anything without knowing who the admins are."
    return
}

if ($adminSids.Count -eq 0) {
    Write-Output "Administrators group came back empty. That's wrong - aborting."
    return
}

Write-Output "Protected admin accounts: $($adminSids.Count) found."
Write-Output ""

$deleted = 0
$skipped = 0

foreach ($u in Get-LocalUser) {

    $sid = $u.SID.Value
    $rid = [int]($sid -split '-')[-1]

    if ($rid -in $protectedRids) {
        Write-Output "SKIP (built-in):  $($u.Name)"
        $skipped++
        continue
    }

    if ($adminSids -contains $sid) {
        Write-Output "SKIP (admin):     $($u.Name)"
        $skipped++
        continue
    }

    if ($DryRun) {
        Write-Output "WOULD DELETE:     $($u.Name)"
        $deleted++
        continue
    }

    try {
        Remove-LocalUser -SID $sid -ErrorAction Stop
        Write-Output "DELETED:          $($u.Name)"
        $deleted++
    } catch {
        Write-Output "FAILED:           $($u.Name) - $_"
    }
}

Write-Output ""
if ($DryRun) {
    Write-Output "DRY RUN - nothing was deleted. $deleted would be removed, $skipped kept."
    Write-Output "Set `$DryRun = `$false to run for real."
} else {
    Write-Output "Done. $deleted deleted, $skipped kept."
}

Write-Output "Script execution completed."
