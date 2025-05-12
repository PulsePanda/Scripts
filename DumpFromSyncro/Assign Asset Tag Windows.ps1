Import-Module $env:SyncroModule

# Rename the computer's hostname
Rename-Computer -NewName $assetTag -Force

# Create a registry entry containing the asset tag ID
$regPath = "HKLM:\SOFTWARE\Umbrella\AssetTag"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force
}
Set-ItemProperty -Path $regPath -Name "TagID" -Value $assetTag

# Set Syncro Field
Set-Asset-Field -Name "Asset Tag" -Value $assetTag