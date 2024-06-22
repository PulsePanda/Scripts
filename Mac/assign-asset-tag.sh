# Function to set hostname based on asset tag
set_hostname() {
    local assetTag
    read -p "Enter the device's asset tag (e.g., SJA1234): " assetTag

    scutil --set ComputerName $assetTag
    scutil --set LocalHostName $assetTag
    scutil --set HostName $assetTag
}

# Function to create a plist file containing the asset tag ID
create_plist() {
    local assetTag=$1
    local plistPath="/Library/Preferences/com.company.assettag.plist"

    defaults write $plistPath TagID $assetTag
}

set_hostname
create_plist $assetTag