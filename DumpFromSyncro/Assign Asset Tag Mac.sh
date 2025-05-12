# Function to set hostname based on asset tag
set_hostname() {
    scutil --set ComputerName $assetTag
    scutil --set LocalHostName $assetTag
    scutil --set HostName $assetTag
}

# Function to create a plist file containing the asset tag ID
create_plist() {
    local assetTag=$1
    local plistPath="/Library/Preferences/com.umbrella.assettag.plist"

    defaults write $plistPath TagID $assetTag
}

set_hostname
create_plist $assetTag
syncro set-asset-field --name="Asset Tag" --value=$assetTag