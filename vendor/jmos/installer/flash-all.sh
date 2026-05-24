#!/bin/bash
# ====================================================================
#              JM OS AUTOMATED FLASHING RUNTIME (Linux/macOS)
# ====================================================================
# Safe, interactive, and seamless installation for JM OS devices.
# Copyright (c) 2026 JM OS Project. All rights reserved.
# ====================================================================

# Colors for terminal styling
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Clear terminal screen
clear

echo -e "${MAGENTA}======================================================================${NC}"
echo -e "${CYAN}    ███████╗ █████╗  ██████╗██╗   ██╗    ██████╗ ███████╗            ${NC}"
echo -e "${CYAN}    ██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝    ██╔══██╗██╔════╝            ${NC}"
echo -e "${CYAN}    █████╗  ███████║╚█████╗   ╚███╔╝     ██║  ██║███████╗            ${NC}"
echo -e "${CYAN}    ██╔══╝  ██╔══██║ ╚═══██╗   ██║       ██║  ██║╚════██║            ${NC}"
echo -e "${CYAN}    ███████╗██║  ██║██████╔╝   ██║       ██████╔╝███████║            ${NC}"
echo -e "${CYAN}    ╚══════╝╚═╝  ╚═╝╚═════╝    ╚═╝       ╚═════╝ ╚══════╝            ${NC}"
echo -e "${MAGENTA}======================================================================${NC}"
echo -e "${GREEN}                  JM OS - Easy Flashing Wizard v1.0                    ${NC}"
echo -e "${MAGENTA}======================================================================${NC}"
echo ""

# Helper to print information
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. Pre-flight checks
info "Starting system pre-flight checks..."

# Check if running as root is NOT needed for fastboot (usually relies on udev rules), but warn about permissions
if [ "$EUID" -ne 0 ]; then
    warn "If fastboot fails to detect your device, run this script as 'sudo bash flash-all.sh'"
fi

# Check if fastboot is installed
if ! command -v fastboot &> /dev/null; then
    error "Fastboot command was not found on your system."
    echo -e "Please install the Android Platform Tools:"
    echo -e "  - macOS (Homebrew): ${CYAN}brew install --cask android-platform-tools${NC}"
    echo -e "  - Ubuntu/Debian:    ${CYAN}sudo apt-get install android-tools-fastboot${NC}"
    echo -e "  - Fedora:           ${CYAN}sudo dnf install android-tools${NC}"
    exit 1
else
    success "Fastboot binary detected: $(fastboot --version | head -n 1)"
fi

# 2. Check for connected device
info "Scanning for devices in fastboot mode..."
device_count=$(fastboot devices | wc -l)

if [ "$device_count" -eq 0 ]; then
    warn "No device detected in fastboot mode."
    echo -e "To connect your device:"
    echo -e "  1. Turn off your device completely."
    echo -e "  2. Hold ${YELLOW}Volume Down + Power${NC} buttons together to enter Bootloader Mode."
    echo -e "  3. Connect your device to this PC via a high-quality USB cable."
    echo ""
    read -p "Press [Enter] once your device is connected and in fastboot mode..."
    
    # Re-scan
    device_count=$(fastboot devices | wc -l)
    if [ "$device_count" -eq 0 ]; then
        error "Device still not detected. Exiting flashing process."
        exit 1
    fi
fi

device_id=$(fastboot devices | awk '{print $1}')
success "Connected Fastboot Device: ${GREEN}$device_id${NC}"

# 3. Double Confirmation and Bootloader Unlocking info
echo ""
echo -e "${YELLOW}======================================================================${NC}"
echo -e "  CRITICAL WARING: This process will WIPE all user data from your device!  "
echo -e "  Ensure your device's bootloader is UNLOCKED before proceeding.       "
echo -e "======================================================================${NC}"
echo ""

read -p "Are you sure you want to install JM OS? (y/N): " choice
if [[ ! "$choice" =~ ^[Yy]$ ]]; then
    info "Installation cancelled by user. No changes were made."
    exit 0
fi

# Ask if they need to unlock the bootloader
read -p "Do you need to unlock your bootloader first? (y/N): " unlock_choice
if [[ "$unlock_choice" =~ ^[Yy]$ ]]; then
    info "Attempting to unlock bootloader..."
    info "Please look at your phone screen and confirm the unlock using the Volume buttons."
    fastboot flashing unlock || fastboot oem unlock
    if [ $? -eq 0 ]; then
        success "Bootloader unlocked successfully!"
        info "Waiting for device to reboot back into fastboot..."
        sleep 5
    else
        error "Bootloader unlock failed or cancelled. Proceeding to flash, but it may fail if not unlocked."
    fi
fi

# 4. Flashing Sequence
info "Starting JM OS Flashing Sequence. DO NOT disconnect your device!"
echo ""

# Find firmware images in the same directory or prompt
firmware_dir="."
if [ ! -f "$firmware_dir/boot.img" ]; then
    warn "Firmware files (boot.img, system.img, etc.) were not found in the current directory."
    read -p "Enter path to firmware directory (or press Enter to search default build output): " user_dir
    if [ -n "$user_dir" ]; then
        firmware_dir="$user_dir"
    else
        firmware_dir="../../out/target/product/generic"
    fi
fi

# Verify directory exists
if [ ! -d "$firmware_dir" ] || [ ! -f "$firmware_dir/boot.img" ]; then
    error "Could not find firmware images (boot.img) at '$firmware_dir'."
    echo "Please make sure you have compiled the ROM or extracted the release zip here."
    exit 1
fi

info "Using firmware images from: ${CYAN}$firmware_dir${NC}"

# Start flashing partitions
flash_partition() {
    local part=$1
    local img="$firmware_dir/$2"
    if [ -f "$img" ]; then
        info "Flashing ${part} partition..."
        fastboot flash "$part" "$img"
        if [ $? -ne 0 ]; then
            error "Failed to flash ${part}! Flashing process aborted."
            exit 1
        fi
        success "${part} flashed successfully."
    else
        warn "Optional image ${img} not found. Skipping ${part}."
    fi
}

# Standard AOSP flashing steps
flash_partition "boot" "boot.img"
flash_partition "dtbo" "dtbo.img"
flash_partition "vendor_boot" "vendor_boot.img"
flash_partition "recovery" "recovery.img"
flash_partition "vbmeta" "vbmeta.img"

# Reboot to fastbootd (logical partition space) for system/product/vendor flashing
info "Rebooting device into FastbootD (Userspace Fastboot)..."
fastboot reboot-fastboot
if [ $? -ne 0 ]; then
    warn "Could not reboot to fastbootd automatically. Please ensure you are in recovery fastbootd."
fi
sleep 5

flash_partition "system" "system.img"
flash_partition "product" "product.img"
flash_partition "vendor" "vendor.img"
flash_partition "system_ext" "system_ext.img"

# 5. Format & Finalize
info "Formatting user data (Factory Reset)..."
fastboot -w
if [ $? -ne 0 ]; then
    warn "Wiping user data failed via standard fastboot -w. Attempting format of userdata partition..."
    fastboot erase userdata
fi

success "All partitions flashed and device formatted successfully!"
info "Rebooting device into your new JM OS... Enjoy!"
fastboot reboot

echo ""
echo -e "${MAGENTA}======================================================================${NC}"
echo -e "${GREEN}      🎉 JM OS HAS BEEN INSTALLED SUCCESSFULLY! 🎉                      ${NC}"
echo -e "${MAGENTA}======================================================================${NC}"
echo "Your device is now rebooting. The first boot may take 2-5 minutes."
echo "Thank you for installing JM OS!"
echo "======================================================================"
