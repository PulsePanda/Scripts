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

:: Define the source directories to copy
set "source_directories=%USERPROFILE%\Desktop %USERPROFILE%\Documents %USERPROFILE%\Downloads %USERPROFILE%\Pictures"

:: Define the destination directory on the flash drive
set "destination_directory=%flash_drive%\Backup"

:: Create the destination directory if it doesn't exist
mkdir "%destination_directory%" 2>nul

:: Copy the source directories to the flash drive
for %%S in (%source_directories%) do (
    if exist "%%S" (
        echo Copying "%%S" to "%destination_directory%"
        xcopy "%%S" "%destination_directory%\%%~nS" /e /i /h /y
    ) else (
        echo "%%S" not found. Skipping.
    )
)

echo Backup completed.
pause
exit /b
