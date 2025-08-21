#!ps

# List of names that the script is looking for in a printer name. Names are separated by "|", 
# for example "Staff|245" will match any printer that contains "Staff" or "245" in its name.
# Names are case sensitive, so "Staff" and "staff" are considered different.
# The script will remove any printer that matches these names.
$printer_names = "Staff|247|staff|STAFF|Sharp|sharp|SHARP|SJA"

# Get all printers with "Staff" or "247" in their names
$printers = Get-Printer | Where-Object { $_.Name -match $printer_names }

# Loop through each printer and remove it
foreach ($printer in $printers) {
    Write-Host "Removing printer: $($printer.Name)"
    Remove-Printer -Name $printer.Name
}
