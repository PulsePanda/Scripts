# Run as Administrator
# Pulls crash-related events from the last 30 days and saves to Desktop

$outputFile = "$env:USERPROFILE\Desktop\crash-events.txt"
$startDate = (Get-Date).AddDays(-30)

$queries = @(
    @{ Log = "System"; Id = 41;   Label = "Kernel-Power (unexpected shutdown / power loss)" },
    @{ Log = "System"; Id = 6008; Label = "Unexpected Shutdown" },
    @{ Log = "System"; Id = 4101; Label = "Display Driver Timeout (TDR)" },
    @{ Log = "System"; Id = 1001; Label = "Windows Error Reporting / BugCheck" },
    @{ Log = "System"; Id = 18;   Label = "Machine Check Exception (hardware fault)" }
)

"=== Crash Event Report ===" | Out-File $outputFile
"Generated: $(Get-Date)" | Out-File $outputFile -Append
"Looking back: 30 days" | Out-File $outputFile -Append
"" | Out-File $outputFile -Append

foreach ($q in $queries) {
    "--- $($q.Label) (Event ID $($q.Id)) ---" | Out-File $outputFile -Append
    try {
        $events = Get-WinEvent -FilterHashtable @{
            LogName   = $q.Log
            Id        = $q.Id
            StartTime = $startDate
        } -ErrorAction Stop

        "$($events.Count) event(s) found:" | Out-File $outputFile -Append
        foreach ($e in $events) {
            "" | Out-File $outputFile -Append
            "  Time: $($e.TimeCreated)" | Out-File $outputFile -Append
            "  $($e.Message)" | Out-File $outputFile -Append
        }
    }
    catch [Exception] {
        "  None found (good)" | Out-File $outputFile -Append
    }
    "" | Out-File $outputFile -Append
}

"=== End of Report ===" | Out-File $outputFile -Append
Write-Host "Done - saved to $outputFile" -ForegroundColor Green
