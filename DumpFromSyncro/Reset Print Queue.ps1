Import-Module $env:SyncroModule

# Stop the Print Spooler service
Stop-Service -Name "Spooler" -Force
Write-Host "Print Spooler service stopped."

# Clear the spool folder
$spoolFolder = "C:\WINDOWS\System32\spool\PRINTERS"
if (Test-Path $spoolFolder) {
    Remove-Item -Path "$spoolFolder\*" -Recurse -Force
    Write-Host "Cleared spool folder: $spoolFolder"
    Log-Activity -Message "Cleared spool folder" -EventName "Spool reset"
} else {
    Write-Host "Spool folder not found: $spoolFolder"
    Log-Activity -Message "Unable to clear spool folder - not found" -EventName "Spool reset"
}

# Start the Print Spooler service
Start-Service -Name "Spooler"
Write-Host "Print Spooler service started."

Log-Activity -Message "Spool service and folder cleared and reset" -EventName "Spool reset"