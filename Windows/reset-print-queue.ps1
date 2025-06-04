#!ps

# This script totally refreshes the print queue by stopping the Print Spooler service, clearing the spool folder, and then restarting the service.

# Stop the Print Spooler service
Stop-Service -Name "Spooler" -Force
Write-Host "Print Spooler service stopped."

# Clear the spool folder
$spoolFolder = "C:\WINDOWS\System32\spool\PRINTERS"
if (Test-Path $spoolFolder) {
    Remove-Item -Path "$spoolFolder\*" -Recurse -Force
    Write-Host "Cleared spool folder: $spoolFolder"
} else {
    Write-Host "Spool folder not found: $spoolFolder"
}

# Start the Print Spooler service
Start-Service -Name "Spooler"
Write-Host "Print Spooler service started."