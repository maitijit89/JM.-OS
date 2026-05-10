#!/bin/bash
# JM OS Build Automation Script

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}      JM OS - Build Command Center     ${NC}"
echo -e "${BLUE}=======================================${NC}"

# Check if repo is initialized
if [ ! -d ".repo" ]; then
    echo "Error: .repo directory not found. Please run repo init first."
    exit 1
fi

# Source environment
echo -e "${BLUE}[1/3] Sourcing environment...${NC}"
source build/envsetup.sh

# Select target
# You can change 'jmos_generic-userdebug' to your specific device codename
DEVICE="lineage_generic"
BUILD_TYPE="userdebug"

echo -e "${BLUE}[2/3] Lunching target: ${DEVICE}-${BUILD_TYPE}${NC}"
lunch ${DEVICE}-${BUILD_TYPE}

# Start Build
echo -e "${BLUE}[3/3] Starting compilation...${NC}"
# Use -j$(nproc) to use all available CPU cores
mka bacon -j$(nproc --all)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build Completed Successfully!${NC}"
else
    echo "Build Failed. Check logs above."
    exit 1
fi
