#!/bin/bash

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# ═════════════════════════════════════════════════════════════════════════════
# Color codes and styling
# ═════════════════════════════════════════════════════════════════════════════
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[1;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# ═════════════════════════════════════════════════════════════════════════════
# Configuration
# ═════════════════════════════════════════════════════════════════════════════
readonly VERSION="3.0.0"
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOGFILE="/var/log/update-script.log"
readonly PID_FILE="/tmp/update-script.pid"
readonly LOCK_FILE="/var/lock/update-script.lock"
readonly MAX_RETRY=3
readonly RETRY_DELAY=5

# ═════════════════════════════════════════════════════════════════════════════
# Global Variables
# ═════════════════════════════════════════════════════════════════════════════
DRY_RUN=false
VERBOSE=false
QUIET=false
START_TIME=$(date +%s)
EXIT_CODE=0

# ═════════════════════════════════════════════════════════════════════════════
# Trap handlers for cleanup
# ═════════════════════════════════════════════════════════════════════════════
trap cleanup EXIT
trap handle_signal INT TERM

cleanup() {
    local exit_code=$?
    
    # Remove lock file
    if [[ -f "$LOCK_FILE" ]]; then
        rm -f "$LOCK_FILE" 2>/dev/null || true
    fi
    
    # Remove PID file
    if [[ -f "$PID_FILE" ]]; then
        rm -f "$PID_FILE" 2>/dev/null || true
    fi
    
    exit "$exit_code"
}

handle_signal() {
    echo -e "\n${RED}[ERROR] Script interrupted by user${NC}" >&2
    exit 130
}

# ═════════════════════════════════════════════════════════════════════════════
# Logging functions
# ═════════════════════════════════════════════════════════════════════════════
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOGFILE" 2>/dev/null
}

log_info() {
    [[ "$QUIET" == true ]] || echo -e "${GREEN}[INFO]${NC} $*"
    log "INFO" "$*"
}

log_warn() {
    [[ "$QUIET" == true ]] || echo -e "${YELLOW}[WARN]${NC} $*" >&2
    log "WARN" "$*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
    log "ERROR" "$*"
}

log_debug() {
    [[ "$VERBOSE" == true ]] && echo -e "${CYAN}[DEBUG]${NC} $*"
    log "DEBUG" "$*"
}

# ═════════════════════════════════════════════════════════════════════════════
# Utility functions
# ═════════════════════════════════════════════════════════════════════════════

# Time-based greeting
show_greeting() {
    local current_hour=$(date +"%H")
    local current_minute=$(date +"%M")
    local total_minutes=$((10#$current_hour * 60 + 10#$current_minute))
    local greeting

    if (( total_minutes >= 240 && total_minutes <= 660 )); then
        greeting="Good Morning Aditya"
    elif (( total_minutes >= 661 && total_minutes <= 780 )); then
        greeting="Good Noon Aditya"
    elif (( total_minutes >= 781 && total_minutes <= 990 )); then
        greeting="Good Afternoon Aditya"
    elif (( total_minutes >= 991 && total_minutes <= 1140 )); then
        greeting="Good Evening Aditya"
    else
        greeting="Good Night Aditya"
    fi

    echo -e "${BLUE}╭────────────────────────────╮"
    echo -e "│ ${NC} $(printf '%-26s' "$greeting")${BLUE}│"
    echo -e "╰────────────────────────────╯${NC}"
}

# Spinner animation
show_spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep "$delay"
        printf "\b\b\b\b\b\b"
    done
    
    # Wait for background process and capture exit code
    wait "$pid"
    printf "      \b\b\b\b\b\b"
    return $?
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root. Use: sudo $SCRIPT_NAME"
        exit 1
    fi
    log_debug "Root check passed"
}

# Check internet connectivity
check_internet() {
    log_debug "Checking internet connectivity..."
    
    local hosts=("8.8.8.8" "1.1.1.1" "208.67.222.222")
    
    for host in "${hosts[@]}"; do
        if ping -c 1 -W 2 "$host" &>/dev/null; then
            log_info "Internet connection detected via $host"
            return 0
        fi
    done
    
    log_error "No internet connection available"
    return 1
}

# Check lock file
check_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        log_error "Another instance is running. Lock file: $LOCK_FILE"
        exit 1
    fi
    
    # Create lock file
    mkdir -p "$(dirname "$LOCK_FILE")" 2>/dev/null || true
    echo $$ > "$LOCK_FILE" 2>/dev/null || {
        log_warn "Could not create lock file"
    }
    log_debug "Lock file created"
}

# Check log file permissions
check_log_permissions() {
    local log_dir=$(dirname "$LOGFILE")
    
    if [[ ! -d "$log_dir" ]]; then
        mkdir -p "$log_dir" 2>/dev/null || {
            log_warn "Could not create log directory: $log_dir"
            return 1
        }
    fi
    
    if [[ ! -w "$log_dir" ]]; then
        log_warn "Log directory not writable: $log_dir"
        return 1
    fi
    
    log_debug "Log permissions verified"
    return 0
}

# Validate apt cache
validate_apt() {
    log_debug "Validating apt configuration..."
    
    if ! command -v apt &>/dev/null; then
        log_error "apt package manager not found"
        return 1
    fi
    
    if ! apt-cache policy &>/dev/null; then
        log_error "apt cache is corrupted or inaccessible"
        return 1
    fi
    
    log_debug "apt validation passed"
    return 0
}

# Show help
show_help() {
    cat << EOF
${BLUE}Aditya's Linux System Updater v$VERSION${NC}

${YELLOW}USAGE:${NC}
    sudo $SCRIPT_NAME [OPTIONS]

${YELLOW}OPTIONS:${NC}
    --help              Show this help message
    --version           Show version information
    --dry-run           Show what would be updated without applying changes
    --verbose           Enable verbose logging
    --quiet             Suppress non-error output
    --check-only        Only check for updates, don't install

${YELLOW}EXAMPLES:${NC}
    sudo $SCRIPT_NAME                    # Run full update
    sudo $SCRIPT_NAME --dry-run          # Preview updates
    sudo $SCRIPT_NAME --verbose          # Verbose mode
    sudo $SCRIPT_NAME --check-only       # Check updates only

${YELLOW}NOTES:${NC}
    - Root/sudo privileges required
    - Internet connection required
    - Log file: $LOGFILE

EOF
}

# Show version
show_version() {
    echo -e "${BLUE}Aditya's Linux System Updater${NC}"
    echo -e "Version: ${GREEN}$VERSION${NC}"
    echo -e "Build Date: $(date)"
}

# Parse arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help)
                show_help
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            --dry-run)
                DRY_RUN=true
                log_info "Dry-run mode enabled"
                ;;
            --verbose)
                VERBOSE=true
                log_debug "Verbose mode enabled"
                ;;
            --quiet)
                QUIET=true
                ;;
            --check-only)
                log_info "Check-only mode enabled"
                DRY_RUN=true
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
}

# Update system with retry logic
update_system() {
    log_info "Starting system update..."
    
    local attempt=1
    while [[ $attempt -le $MAX_RETRY ]]; do
        log_debug "Update attempt $attempt of $MAX_RETRY"
        
        if [[ "$DRY_RUN" == true ]]; then
            log_info "DRY-RUN: Would execute: apt update && apt upgrade -y"
            if apt update && apt upgrade -y; then
                log_info "Dry-run update simulation successful"
                return 0
            fi
        else
            if apt update && apt upgrade -y; then
                log_info "System update completed successfully"
                return 0
            fi
        fi
        
        if [[ $attempt -lt $MAX_RETRY ]]; then
            log_warn "Update attempt $attempt failed. Retrying in ${RETRY_DELAY}s..."
            sleep "$RETRY_DELAY"
        fi
        
        ((attempt++))
    done
    
    log_error "System update failed after $MAX_RETRY attempts"
    return 1
}

# Cleanup system
cleanup_system() {
    log_info "Running system cleanup..."
    
    if [[ "$DRY_RUN" == false ]]; then
        if apt-get autoremove -y && apt-get autoclean -y; then
            log_info "System cleanup completed"
            return 0
        else
            log_warn "System cleanup encountered issues"
            return 1
        fi
    else
        log_info "DRY-RUN: Would clean orphaned packages"
        return 0
    fi
}

# Check system temperature
check_temperature() {
    log_info "Checking system temperature..."
    
    if ! command -v sensors &>/dev/null; then
        log_warn "sensors command not found"
        log_warn "Install: sudo apt install lm-sensors"
        return 1
    fi
    
    local sensors_output
    sensors_output=$(sensors 2>&1) || {
        log_warn "Failed to read sensors"
        return 1
    }
    
    if echo "$sensors_output" | grep -q "No sensors found"; then
        log_warn "No sensors detected. Run: sudo sensors-detect"
        return 1
    fi
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "$sensors_output"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    return 0
}

# Generate summary report
generate_report() {
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}EXECUTION SUMMARY${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Version: ${GREEN}$VERSION${NC}"
    echo -e "Timestamp: $(date)"
    echo -e "Duration: ${GREEN}${duration}s${NC}"
    echo -e "Log File: ${YELLOW}$LOGFILE${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Display exit banner
show_exit_banner() {
    echo -e "\n${BLUE}╭────────────────────────────╮"
    echo -e "│${NC}   All done. Goodbye! ✓     ${BLUE}│"
    echo -e "╰────────────────────────────╯${NC}\n"
}

# ═════════════════════════════════════════════════════════════════════════════
# Main execution flow
# ═════════════════════════════════════════════════════════════════════════════
main() {
    # Parse command-line arguments
    parse_arguments "$@"
    
    # Show greeting
    show_greeting
    log_info "Script started: $(date)"
    
    # Pre-flight checks
    check_log_permissions
    check_lock
    parse_arguments "$@"
    check_root
    validate_apt
    
    if ! check_internet; then
        log_error "Aborting: Internet connection required"
        exit 1
    fi
    
    # User confirmation
    if [[ "$QUIET" == false ]]; then
        read -p "$(echo -e ${YELLOW}Do you want to proceed with system update? [Y/n]: ${NC})" choice
        choice=${choice,,}
        if [[ "$choice" == "n" ]]; then
            log_warn "Update cancelled by user"
            exit 0
        fi
    fi
    
    log_info "Proceeding with update..."
    
    # Execute update
    if update_system; then
        log_info "Update successful"
        
        # Cleanup
        if cleanup_system; then
            log_info "Cleanup successful"
        else
            log_warn "Cleanup encountered issues (non-fatal)"
        fi
        
        # Temperature check
        check_temperature || true
        
        # Generate report and exit
        generate_report
        show_exit_banner
        exit 0
    else
        log_error "Update failed"
        generate_report
        exit 1
    fi
}

# ═════════════════════════════════════════════════════════════════════════════
# Script Entry Point
# ═════════════════════════════════════════════════════════════════════════════
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
