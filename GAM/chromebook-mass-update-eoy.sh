# Each of these script lines is meant to be ran individually in the terminal. This file is NOT a runnable script.
# Replace the .csv path with the path to your own .csv file.
# This script udpates the OU, location, assetID, and notes for each Chromebook in the spreadsheet.
# This script searches for the devices by deviceID, NOT serial number.
# This script is not meant to be ran with the downloaded google device .csv. 
# This script expects the .csv file to ONLY contain devices meant to be re-enabled.
# Information formatted as ~~XXX~~ refers to the column headers in the .csv file.


# updates the device info with that in spreadsheet
gam csv /Users/Austin/Desktop/sja-cb-test.csv gam update cros ~~deviceID~~ ou ~~orgUnitPath~~ location ~~location~~ assetid ~~assetID~~ notes ~~notes~~

# reenables chromebooks in spreadsheet
gam csv /Users/Austin/Desktop/sja-cb-test.csv gam update cros ~~deviceID~~ action reenable