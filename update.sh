#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}╭────────────────────────────╮"
echo -e "│    ⚙️  Created by Aditya    │"
echo -e "╰────────────────────────────╯${NC}"

# Dry-run mode check
if [[ "$1" == "--dry-run" ]]; then
    echo -e "${YELLOW}🔍 Dry run mode. No changes will be made.${NC}"
    apt update --dry-run
    exit 0
fi

# Check for root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}🚫 You are not the root user. Please run with sudo.${NC}"
    exit 1
fi

# Check internet connection
if ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1; then
    echo -e "${GREEN}🌐 Internet connection detected.${NC}"
    echo -e "${YELLOW}🔄 Updating your system...${NC}"

    # Perform update
    apt update && apt full-upgrade -y -o APT::Get::Always-Include-Phased-Updates=true

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ System successfully updated!${NC}"
        
        # Cleanup
        echo -e "${YELLOW}🧹 Cleaning up...${NC}"
        apt autoremove -y && apt autoclean -y
        echo -e "${GREEN}✨ Cleanup done!${NC}"
    else
        echo -e "${RED}❌ Something went wrong during the update.${NC}"
    fi
else
    echo -e "${RED}❌ No internet connection. Check your network.${NC}"
fi
