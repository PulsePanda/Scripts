#!ps

# Google Drive File ID (this is the part of the file URL that is located at /file/d/FILE_ID/view...)
$FileID = "14VIWr_KEayZJNcrx1XjkX4X0MuUz9yFN"

# Create a temporary file path
$TempFilePath = "$env:TEMP\Submit Ticket.url"

# Build the direct download URL
$DownloadURL = "https://drive.google.com/uc?export=download&id=$FileID"

# Download the shortcut file
Invoke-WebRequest -Uri $DownloadURL -OutFile $TempFilePath

# Get all user profiles
$UserProfiles = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.Special -eq $false }

foreach ($UserProfile in $UserProfiles) {
    # Construct the desktop path for each user
    $DesktopPath = Join-Path -Path $UserProfile.LocalPath -ChildPath 'Desktop'
    
    # Ensure the desktop directory exists
    if (Test-Path $DesktopPath) {
        # Copy the shortcut file to the user's desktop
        Copy-Item -Path $TempFilePath -Destination $DesktopPath -Force
    }
}

# Cleanup temporary file
Remove-Item -Path $TempFilePath -Force