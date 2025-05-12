# Define the path to the installer
$installerPath = "C:\Users\$env:USERNAME\Downloads\ricoh-office-driver.exe"

# Start the installer with administrative privileges
Start-Process -FilePath $installerPath -Verb RunAs
