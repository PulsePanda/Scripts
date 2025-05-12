# Get all printers with "Staff" or "247" in their names
$printers = Get-Printer | Where-Object { $_.Name -match "Staff|247|staff|STAFF|Sharp|sharp|SHARP|SJA" }

# Loop through each printer and remove it
foreach ($printer in $printers) {
    Write-Host "Removing printer: $($printer.Name)"
    Remove-Printer -Name $printer.Name
}
