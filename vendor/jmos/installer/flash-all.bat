@echo off
:: ====================================================================
::              JM OS AUTOMATED FLASHING RUNTIME (Windows CMD)
:: ====================================================================
:: Safe, interactive, and seamless installation for JM OS devices.
:: Copyright (c) 2026 JM OS Project. All rights reserved.
:: ====================================================================

title JM OS - Easy Flashing Wizard v1.0
color 0B
cls

echo ======================================================================
echo     ███████╗ █████╗  ██████╗██╗   ██╗    ██████╗ ███████╗            
echo     ██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝    ██╔══██╗██╔════╝            
echo     █████╗  ███████║╚█████╗   ╚███╔╝     ██║  ██║███████╗            
echo     ██╔══╝  ██╔══██║ ╚═══██╗   ██║       ██║  ██║╚════██║            
echo     ███████╗██║  ██║██████╔╝   ██║       ██████╔╝███████║            
echo     ╚══════╝╚═╝  ╚═╝╚═════╝    ╚═╝       ╚═════╝ ╚══════╝            
echo ======================================================================
echo                   JM OS - Easy Flashing Wizard v1.0                   
echo ======================================================================
echo.

:: 1. Pre-flight checks
echo [INFO] Starting system pre-flight checks...

:: Check if fastboot is installed
where fastboot >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Fastboot command was not found on your system.
    echo Please make sure to:
    echo   1. Download Android Platform Tools for Windows.
    echo   2. Extract the ZIP folder to a convenient place.
    echo   3. Add the extracted folder path to your System Environment variables,
    echo      or copy fastboot.exe and adb.exe to this directory.
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo [SUCCESS] Fastboot binary detected.
echo.

:: 2. Check for connected device
echo [INFO] Scanning for devices in fastboot mode...
fastboot devices > temp_devices.txt
set /p ConnectedDevice=<temp_devices.txt
del temp_devices.txt

if "%ConnectedDevice%"=="" (
    echo [WARNING] No device detected in fastboot mode.
    echo To connect your device:
    echo   1. Turn off your device completely.
    echo   2. Hold [Volume Down] and [Power] buttons together to enter Bootloader Mode.
    echo   3. Connect your device to this PC via a high-quality USB cable.
    echo   4. (Windows Only) Ensure Google USB Drivers are installed in Device Manager.
    echo.
    echo Press [Enter] once your device is connected and in fastboot mode...
    pause >nul
    
    fastboot devices > temp_devices.txt
    set /p ConnectedDevice=<temp_devices.txt
    del temp_devices.txt
    
    if "%ConnectedDevice%"=="" (
        echo [ERROR] Device still not detected. Exiting flashing process.
        echo Press any key to exit...
        pause >nul
        exit /b 1
    )
)

echo [SUCCESS] Connected Device detected!
echo.

:: 3. Double Confirmation and Bootloader Unlocking
echo ======================================================================
echo   CRITICAL WARNING: This process will WIPE all user data from your device!
echo   Ensure your device's bootloader is UNLOCKED before proceeding.
echo ======================================================================
echo.

set /p Choice=Are you sure you want to install JM OS? (y/N): 
if /i not "%Choice%"=="y" (
    echo [INFO] Installation cancelled by user. No changes were made.
    pause
    exit /b 0
)

set /p UnlockChoice=Do you need to unlock your bootloader first? (y/N): 
if /i "%UnlockChoice%"=="y" (
    echo [INFO] Attempting to unlock bootloader...
    echo Please look at your phone screen and confirm the unlock using the Volume buttons.
    fastboot flashing unlock
    if %errorlevel% neq 0 (
        fastboot oem unlock
    )
    echo [SUCCESS] Bootloader unlock command sent.
    echo Waiting 5 seconds for device to update...
    timeout /t 5 >nul
)

:: 4. Flashing Sequence
echo [INFO] Starting JM OS Flashing Sequence. DO NOT disconnect your device!
echo.

set FirmwareDir=.
if not exist "%FirmwareDir%\boot.img" (
    echo [WARNING] Firmware files (boot.img) were not found in the current directory.
    set /p FirmwareDir=Enter path to firmware directory (or press Enter to search default build output): 
    if "%FirmwareDir%"=="" (
        set FirmwareDir=..\..\out\target\product\generic
    )
)

if not exist "%FirmwareDir%\boot.img" (
    echo [ERROR] Could not find firmware images (boot.img) at "%FirmwareDir%".
    echo Please ensure you compiled the ROM or extracted the release zip here.
    pause
    exit /b 1
)

echo [INFO] Using firmware images from: %FirmwareDir%
echo.

:: Helper flashing commands
call :FlashPartition boot boot.img
call :FlashPartition dtbo dtbo.img
call :FlashPartition vendor_boot vendor_boot.img
call :FlashPartition recovery recovery.img
call :FlashPartition vbmeta vbmeta.img

:: Reboot to fastbootd
echo [INFO] Rebooting device into FastbootD (Userspace Fastboot)...
fastboot reboot-fastboot
if %errorlevel% neq 0 (
    echo [WARNING] Could not reboot to fastbootd automatically. Make sure device enters recovery/fastbootd.
)
timeout /t 5 >nul

call :FlashPartition system system.img
call :FlashPartition product product.img
call :FlashPartition vendor vendor.img
call :FlashPartition system_ext system_ext.img

:: 5. Format & Finalize
echo [INFO] Formatting user data (Factory Reset)...
fastboot -w
if %errorlevel% neq 0 (
    echo [WARNING] Wiping failed via fastboot -w. Attempting userdata format...
    fastboot erase userdata
)

echo [SUCCESS] All partitions flashed and device formatted successfully!
echo [INFO] Rebooting device into your new JM OS... Enjoy!
fastboot reboot

echo.
echo ======================================================================
echo       🎉 JM OS HAS BEEN INSTALLED SUCCESSFULLY! 🎉
echo ======================================================================
echo Your device is now rebooting. The first boot may take 2-5 minutes.
echo Thank you for installing JM OS!
echo ======================================================================
pause
exit /b 0

:: Flashing Subroutine
:FlashPartition
set PartitionName=%1
set ImageFile=%2
if exist "%FirmwareDir%\%ImageFile%" (
    echo [INFO] Flashing %PartitionName% partition...
    fastboot flash %PartitionName% "%FirmwareDir%\%ImageFile%"
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to flash %PartitionName%! Flashing process aborted.
        pause
        exit /b 1
    )
    echo [SUCCESS] %PartitionName% flashed successfully.
) else (
    echo [WARNING] Optional image %ImageFile% not found. Skipping %PartitionName%.
)
exit /b 0
