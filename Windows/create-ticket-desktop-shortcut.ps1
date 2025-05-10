#!ps

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
$Shortcut.TargetPath = "https://umbrellasystems.freshdesk.com/support/tickets/new"
$Shortcut.Arguments = 'URL'
$ShortCut.WindowStyle = 1;
$Shortcut.IconLocation = $ShortCut.IconLocation = $TempFilePath
$ShortCut.Description = ''
$ShortCut.Save()