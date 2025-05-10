# This script downloads a google drive file to all user's desktop

# Google Drive File ID
$FileID = "YOUR_FILE_ID"

# Create a temporary file path
$TempFilePath = "$env:TEMP\GoogleDriveFile"

# Build the direct download URL
$DownloadURL = "https://drive.google.com/uc?export=download&id=$FileID"

# Download the file to the temporary path
Invoke-WebRequest -Uri $DownloadURL -OutFile $TempFilePath

# Get the profile directories
$UserProfiles = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.Special -eq $false }

foreach ($UserProfile in $UserProfiles) {
    # Construct the Desktop path for each user
    $DesktopPath = Join-Path -Path $UserProfile.LocalPath -ChildPath 'Desktop'
    
    # Ensure the Desktop directory exists
    if (Test-Path $DesktopPath) {
        # Copy the file to the user's desktop
        Copy-Item -Path $TempFilePath -Destination $DesktopPath -Force
    }
}

# Cleanup
Remove-Item -Path $TempFilePath -Force
