#!ps

# this script sets a computers hostname to the asset tag ID, and creates a registry entry containing the asset tag ID.

# !!!SET ASSET TAG ID!!!
$assetTag = "SJAXXXX"
Rename-Computer -NewName $assetTag -Force -Restart

# Create a registry entry containing the asset tag ID
$regPath = "HKLM:\SOFTWARE\Company\AssetTag"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force
}
Set-ItemProperty -Path $regPath -Name "TagID" -Value $assetTag
