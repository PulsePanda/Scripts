# Ask for the device's asset tag and set the hostname to that tag
$assetTag = Read-Host -Prompt "Enter the device's asset tag (e.g., SJA1234)"
Rename-Computer -NewName $assetTag -Force -Restart

# Create a registry entry containing the asset tag ID
$regPath = "HKLM:\SOFTWARE\Company\AssetTag"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force
}
Set-ItemProperty -Path $regPath -Name "TagID" -Value $assetTag
