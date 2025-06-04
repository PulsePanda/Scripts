#!ps

# This script creates the "Create Ticket" desktop shortcut for Umbrella Systems Freshdesk support tickets.

# Google Drive File ID (this is the part of the file URL that is located at /file/d/FILE_ID/view...)
$FileID = "1ItARxNR6o0IFwnoF9pAPRc0euD98hWuR"

# Create a temporary file path
# $TempFilePath = "$env:TEMP\umbshortcut.ico"
$TempFilePath = "c:\users\public\umbshortcut.ico"

# Build the direct download URL
$DownloadURL = "https://drive.google.com/uc?export=download&id=$FileID"

# Download the shortcut file
Invoke-WebRequest -Uri $DownloadURL -OutFile $TempFilePath

$Shell = New-Object -ComObject ("WScript.Shell")
$shortcut = $Shell.CreateShortcut('c:\users\public\desktop\Create Ticket.lnk')

# Path to Chrome
$chromePath = "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"

# Path to the Edge executable
$edgePath = "msedge.exe"

# Check if Chrome exists
if (Test-Path $chromePath) {
    $Shortcut.TargetPath = $chromePath
} else {
    # Use Edge if Chrome is not found
    $Shortcut.TargetPath = $edgePath
}

$Shortcut.Arguments = "https://umbrellasystems.freshdesk.com/support/tickets/new"
$ShortCut.WindowStyle = 1;
$Shortcut.IconLocation = $ShortCut.IconLocation = $TempFilePath
$ShortCut.Description = ''
$ShortCut.Save()