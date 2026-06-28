# ⚙️ Update Tool v3.0.0
A production-ready, enterprise-grade update script for Ubuntu and Debian-based systems.  
Crafted with discipline, clarity, and a strong dislike for outdated packages — by **Aditya**.

---

## 🎯 What's New in v3.0.0

**Complete overhaul with professional-grade features:**
- ✨ Structured logging with timestamps and log levels
- ✨ Automatic retry logic (3 attempts on failure)
- ✨ Concurrency prevention (lock file mechanism)
- ✨ Multiple operation modes (verbose, quiet, check-only)
- ✨ Execution summary with duration tracking
- ✨ Full signal handling (graceful Ctrl+C)
- ✨ 5-point validation system
- ✨ Better error messages and clarity

---

## 📊 v2.0.0 vs v3.0.0 Comparison

| v2.0.0 Issues ❌ | v3.0.0 Features ✅ |
|---|---|
| **No timestamps** - Messages lack date/time | **Full timestamps** - 2026-06-28 08:37:09 [INFO] |
| **No log levels** - Can't distinguish INFO/WARN/ERROR | **4 log levels** - INFO, WARN, ERROR, DEBUG |
| **Messy spinner** - Overlaps with text output | **Clean output** - Structured & color-coded |
| **Confusing output** - "Success" shown even on abort | **Error clarity** - Clear success/failure status |
| **No summary** - No execution time or stats | **Execution summary** - Duration: 45s, Version: 3.0.0 |
| **Unstructured log** - Hard to parse /var/log/ | **Structured logging** - [LEVEL] message format |
| **Limited modes** - Only 3 options (--help, --version, --dry-run) | **6 operation modes** - --verbose, --quiet, --check-only |
| **No error handling** - Script continues on failure | **Robust error handling** - Retry logic + signal handling |

---

## 🚀 Core Features

### System Management
- ✅ Checks for **root privileges**
- ✅ Verifies **internet connection** (multiple DNS servers for redundancy)
- ✅ Validates **apt package manager** and cache integrity
- ✅ Prevents **concurrent executions** (lock file protection)
- ✅ Automatic **signal handling** (Ctrl+C cleanup)

### Update Operations
- ✅ Runs `apt update` + `apt upgrade -y` (full system upgrade)
- ✅ Auto-runs `apt-get autoremove -y` + `apt-get autoclean -y`
- ✅ Automatic **retry logic** (3 attempts, 5s delay between retries)
- ✅ Dry-run mode to preview updates without applying
- ✅ Check-only mode to see available updates

### Logging & Monitoring
- ✅ **Structured logging** with 4 log levels (INFO, WARN, ERROR, DEBUG)
- ✅ **Timestamps** on every message for audit trails
- ✅ Logs to `/var/log/update-script.log` with full details
- ✅ **Execution summary** with duration, version, and timing
- ✅ Temperature monitoring via `sensors` command

### User Experience
- ✅ **Time-based greeting** (Good Morning/Afternoon/Evening/Night)
- ✅ Default confirmation prompt is **Yes** (`[Y/n]`)
- ✅ Clean, color-coded output (INFO=Green, WARN=Yellow, ERROR=Red, DEBUG=Cyan)
- ✅ Spinner animation during operations
- ✅ Multiple operation modes for different use cases

---

## 📋 Operation Modes

### Standard Mode
Run with full output and interactive prompt:
```bash
sudo ./update.sh
```
Output includes timestamps, log levels, and execution summary.

### Dry-Run Mode
Preview what would be updated without making changes:
```bash
sudo ./update.sh --dry-run
```

### Check-Only Mode  
Same as dry-run (check for updates without installing):
```bash
sudo ./update.sh --check-only
```

### Verbose Mode
Show debug messages for detailed troubleshooting:
```bash
sudo ./update.sh --verbose
```
Includes `[DEBUG]` messages showing every validation step.

### Quiet Mode
Suppress non-error output (only warnings/errors shown):
```bash
sudo ./update.sh --quiet
```
Useful for cron jobs and automation.

### Help & Version
```bash
sudo ./update.sh --help          # Show all options
sudo ./update.sh --version       # Show version info
```

---

## 🛠 Installation

### Option 1: Direct Run (Recommended for Testing)
```bash
# Download/copy the script
chmod +x update.sh

# Run it
sudo ./update.sh
```

### Option 2: Global Command (Recommended for Daily Use)
```bash
# Copy to system PATH
sudo cp update.sh /usr/local/bin/update

# Make executable (if not already)
sudo chmod +x /usr/local/bin/update

# Now you can run from anywhere
sudo update
```

### Option 3: With Custom Location
```bash
# Store in a specific directory
sudo mkdir -p /opt/aditya-tools
sudo cp update.sh /opt/aditya-tools/update

# Create a symlink
sudo ln -s /opt/aditya-tools/update /usr/local/bin/update

# Run it
sudo update
```

---

## 📊 Output Examples

### Standard Execution
```
╭────────────────────────────╮
│ Good Morning Aditya        │
╰────────────────────────────╯

[INFO] Script started: 2026-06-28 08:37:09
[DEBUG] Root check passed
[DEBUG] Log permissions verified
[INFO] Internet connection detected via 8.8.8.8

Do you want to proceed with system update? [Y/n]: Y

[INFO] Proceeding with update...
[INFO] System update completed successfully
[INFO] System cleanup completed
[INFO] Checking system temperature...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EXECUTION SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Version: 3.0.0
Timestamp: 2026-06-28 08:37:54
Duration: 45s
Log File: /var/log/update-script.log
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

╭────────────────────────────╮
│   All done. Goodbye! ✓     │
╰────────────────────────────╯
```

### Verbose Mode
```
[INFO] Script started: 2026-06-28 08:37:09
[DEBUG] Root check passed
[DEBUG] Log permissions verified
[DEBUG] Lock file created
[DEBUG] Validating apt configuration...
[DEBUG] apt validation passed
[DEBUG] Checking internet connectivity...
[DEBUG] Testing connection via 8.8.8.8
[INFO] Internet connection detected via 8.8.8.8
[DEBUG] User confirmed update
[DEBUG] Update attempt 1 of 3
[INFO] System update completed successfully
```

### Log File Output
```
2026-06-28 08:37:09 [INFO] Script started: 2026-06-28 08:37:09
2026-06-28 08:37:09 [DEBUG] Root check passed
2026-06-28 08:37:09 [DEBUG] Log permissions verified
2026-06-28 08:37:09 [INFO] Internet connection detected via 8.8.8.8
2026-06-28 08:37:10 [INFO] System update completed successfully
2026-06-28 08:37:56 [INFO] System cleanup completed
```

---

## 🔧 Configuration

Edit these constants in the script to customize behavior:

```bash
readonly VERSION="3.0.0"              # Script version
readonly LOGFILE="/var/log/update-script.log"  # Log location
readonly MAX_RETRY=3                  # Retry attempts on failure
readonly RETRY_DELAY=5                # Delay between retries (seconds)
```

---

## 📝 Logging

### View Live Logs
```bash
tail -f /var/log/update-script.log
```

### View Recent Updates
```bash
grep "\[INFO\] System update" /var/log/update-script.log | tail -20
```

### Find Errors
```bash
grep "\[ERROR\]" /var/log/update-script.log
```

### View Execution Times
```bash
grep "Duration:" /var/log/update-script.log
```

### Check Specific Date
```bash
grep "2026-06-28" /var/log/update-script.log
```

---

## ⚙️ Automation & Cron

### Run Daily at 2 AM (Quiet Mode)
```bash
0 2 * * * /usr/local/bin/update --quiet
```

### Run Weekly on Sunday
```bash
0 3 * * 0 /usr/local/bin/update --quiet
```

### Crontab Setup
```bash
# Edit crontab
sudo crontab -e

# Add this line (runs daily at 2 AM)
0 2 * * * /usr/local/bin/update --quiet 2>&1
```

### View Cron Logs
```bash
sudo tail -f /var/log/syslog | grep update
```

---

## 🔐 Security Features

- ✅ **Root privilege check** - Prevents accidental unprivileged execution
- ✅ **Lock file** - Prevents multiple concurrent runs (race condition safe)
- ✅ **Signal handling** - Graceful cleanup on Ctrl+C
- ✅ **Permission validation** - Checks log file permissions before writing
- ✅ **Read-only config** - All constants are immutable
- ✅ **Multiple internet checks** - Redundant DNS servers (8.8.8.8, 1.1.1.1, 208.67.222.222)

---

## 🐛 Troubleshooting

### Issue: "You are not the root user"
**Solution:** Run with sudo
```bash
sudo update.sh
```

### Issue: "Another instance is running"
**Solution:** Another copy of the script is already running. Wait or delete lock file:
```bash
sudo rm /var/lock/update-script.lock
```

### Issue: "No internet connection available"
**Solution:** Check your network connection
```bash
ping 8.8.8.8
ping 1.1.1.1
```

### Issue: "sensors not found"
**Solution:** Install lm-sensors
```bash
sudo apt install lm-sensors
sudo sensors-detect  # Run sensors-detect once
```

### Issue: "apt cache is corrupted"
**Solution:** Fix apt cache
```bash
sudo apt clean
sudo apt autoclean
sudo apt --fix-broken install
```

### View Detailed Logs
**Solution:** Run in verbose mode
```bash
sudo update.sh --verbose
```

---

## 📊 System Requirements

- **OS:** Ubuntu 18.04+ or Debian 9+
- **Privileges:** Root/sudo access required
- **Bash:** Version 4.0+
- **Internet:** Active connection required
- **Disk Space:** At least 100 MB free
- **Optional:** lm-sensors for temperature monitoring

---

## ⚠️ Important Warnings

### Production Systems
- ⚠️ Test on non-critical systems first
- ⚠️ Create a backup or snapshot before running
- ⚠️ Run during maintenance windows
- ⚠️ Monitor the system after updates

### Package Management
- ⚠️ This script applies ALL available updates
- ⚠️ No version pinning or exclusions
- ⚠️ Some packages may require restarts
- ⚠️ Kernel updates require reboot

### General Safety
- ✅ Always run with sudo
- ✅ Ensure stable internet connection
- ✅ Check disk space before running
- ✅ Review logs after completion
- ✅ Test in VM/dev environment first

**You are responsible for your system. This script just makes it easier to manage.**

---

## 📈 Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Generic error / Update failed |
| 130 | Script interrupted by user (Ctrl+C) |

---

## 📚 Files

- `update.sh` - Main script (v3.0.0)
- `README.md` - This file
- `CHANGELOG.md` - Full changelog and version history
- `LOG_MANAGEMENT_GUIDE.md` - Log file management guide
- `OUTPUT_COMPARISON.md` - Before/after output examples

---

## 🤝 Contributing

Found a bug or have a feature request?
- Test on your system
- Check logs with `--verbose` flag
- Document the issue
- Provide error output

---

## 📜 License

Free to use and modify for personal/commercial use.  
Attribution appreciated but not required.

---

## 🎉 Credits

Built with attention to detail by **Aditya**.  
Inspired by the need for clean, reliable system maintenance.

---

## 📞 Support

### Getting Help
1. Check `/var/log/update-script.log` for error details
2. Run with `--verbose` flag for debug output
3. Try `--dry-run` to preview without changes
4. Check system requirements above

### Common Commands
```bash
# Check script version
sudo update.sh --version

# Preview updates
sudo update.sh --dry-run

# Debug mode
sudo update.sh --verbose

# View last 50 log lines
tail -50 /var/log/update-script.log

# Check for errors
grep "\[ERROR\]" /var/log/update-script.log
```

---

**Version:** 3.0.0  
**Last Updated:** June 28, 2026  
**Status:** ✅ Production Ready
