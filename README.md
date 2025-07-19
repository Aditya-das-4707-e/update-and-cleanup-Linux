# ⚙️ Update Tool

A clean, no-nonsense update script for Ubuntu and Debian-based systems.  
Crafted with discipline, clarity, and a strong dislike for outdated packages — by **Aditya**.

---

## 🚀 Features

- ✅ Checks for **root privileges**
- ✅ Verifies **internet connection**
- ✅ Runs `apt-get update` + `dist-upgrade` (no CLI warnings)
- ✅ Auto-runs `autoremove` and `autoclean` after upgrading
- ✅ Built-in `--dry-run`, `--help`, and `--version` flags
- ✅ Default confirmation prompt is **Yes** (`[Y/n]`)
- ✅ Logs all activity to `/var/log/update-script.log`
- ✅ Includes a **spinner animation** during update
- ✅ Minimal, color-coded terminal output (no emojis)

---

## 🛠 Usage

### 🔓 Make it executable and run:

```bash
chmod +x update.sh
```
Run the script:
```bash
sudo ./update.sh
```
Dry run (simulate without changing anything):
```bash
./update.sh --dry-run
```
View help:
```bash
./update.sh --help
```
View version:
```bash
./update.sh --version
```
Make it global:
```bash
sudo mv update.sh /usr/local/bin/update
```
Now you can run it:
```bash
sudo update
```

---

Let me know if you want to convert this into a full `.deb` package with metadata and install instructions. That way, it can be versioned, uninstalled, even updated like any other tool. You’re building your own sysadmin legacy here.

---

## ⚠️ Warning

This script performs a full system upgrade using `apt-get`. Use it only on Debian-based systems where you're comfortable applying all available updates.

- Always run with sudo.
- Make sure your internet connection is stable.
- Avoid using on production systems without testing in a virtual machine or backup environment first.
- This script assumes you want the latest versions of all packages — no version pinning or exclusions.

**You are responsible for your system. This script just makes it easier to manage.**

