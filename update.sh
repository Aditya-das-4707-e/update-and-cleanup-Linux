#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Version
VERSION="1.3.0"

# Log file
LOGFILE="/var/log/update-script.log"

# Banner
echo -e "${BLUE}╭────────────────────────────╮"
echo -e "│     Created by Aditya      │"
echo -e "╰────────────────────────────╯${NC}"

# Help option
if [[ "$1" == "--help" ]]; then
    echo -e "${BLUE}Usage: sudo ./update.sh [--dry-run | --help | --version]${NC}"
    echo -e "${YELLOW}--dry-run${NC}   : Show what would be updated without applying changes"
    echo -e "${YELLOW}--help${NC}      : Show this help message"
    echo -e "${YELLOW}--version${NC}   : Show version information"
    exit 0
fi

# Version option
if [[ "$1" == "--version" ]]; then
    echo -e "${BLUE}Aditya’s Linux Updater v$VERSION${NC}"
    exit 0
fi

# Dry-run mode
if [[ "$1" == "--dry-run" ]]; then
    echo -e "${YELLOW}Dry run mode. No changes will be made.${NC}"
    apt-get update && apt-get -s dist-upgrade
    exit 0
fi

# Root check
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}You are not the root user. Please run with sudo.${NC}"
    exit 1
fi

# Start logging
exec > >(tee -a "$LOGFILE") 2>&1

# Check internet
if ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1; then
    echo -e "${GREEN}Internet connection detected.${NC}"
    
    read -p "$(echo -e ${YELLOW}Do you want to proceed with system update? [Y/n]: ${NC})" choice
    choice=${choice,,} # to lowercase
    if [[ "$choice" == "n" ]]; then
        echo -e "${RED}Update cancelled by user.${NC}"
        exit 1
    else
        echo -e "${GREEN}Proceeding with update...${NC}"
    fi

    # Spinner
    show_spinner() {
        local pid=$!
        local delay=0.1
        local spinstr='|/-\'
        while [ "$(ps -p $pid -o comm= 2>/dev/null)" ]; do
            local temp=${spinstr#?}
            printf " [%c]  " "$spinstr"
            spinstr=$temp${spinstr%"$temp"}
            sleep $delay
            printf "\b\b\b\b\b\b"
        done
        printf "      \b\b\b\b\b\b"
    }

    # Update + upgrade
    (
        apt-get update && apt-get dist-upgrade -y
    ) & show_spinner

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}System successfully updated.${NC}"
        
        echo -e "${YELLOW}Cleaning up...${NC}"
        apt-get autoremove -y && apt-get autoclean -y
        echo -e "${GREEN}Cleanup done.${NC}"
    else
        echo -e "${RED}Something went wrong during the update.${NC}"
    fi
else
    echo -e "${RED}No internet connection. Check your network.${NC}"
fi

# Exit banner
echo -e "${BLUE}╭────────────────────────────╮"
echo -e "│     All done. Goodbye!     │"
echo -e "╰────────────────────────────╯${NC}"
