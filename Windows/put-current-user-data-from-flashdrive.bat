@echo off
setlocal enabledelayedexpansion

:: Detect the drive letter of the flash drive
for %%D in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%D:\flashdrive_marker.txt" (
        set "flash_drive=%%D:"
        goto :found_flash_drive
    )
)

:found_flash_drive
:: Ensure flash drive letter is set
if not defined flash_drive (
    echo Flash drive not found!
    pause
    exit /b
)

:: Define the source directory on the flash drive
set "source_directory=%flash_drive%\Backup"

:: Define the destination directories for Desktop, Documents, Downloads, Pictures
set "destination_directories=%USERPROFILE%\Desktop %USERPROFILE%\Documents %USERPROFILE%\Downloads %USERPROFILE%\Pictures"

:: Copy the data from the flash drive to the user's profile directories
for %%D in (%destination_directories%) do (
    set "source_path=!source_directory!\%%~nxD"
    if exist "!source_path!" (
        echo Copying "!source_path!" to "%%D"
        xcopy "!source_path!" "%%D" /e /i /h /y
    ) else (
        echo "!source_path!" not found. Skipping.
    )
)

:: Prepare the flash drive for the next computer by deleting copied data
echo Deleting copied data from the flash drive...
rd /s /q "%source_directory%"

echo Data transfer completed.
pause
exit /b
