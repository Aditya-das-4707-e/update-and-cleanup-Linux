# ⚙️ Update Tool

A forceful, no-nonsense update script for Ubuntu and Debian-based systems.  
Built with ❤️ and rage against outdated packages by **Aditya**.

---

## 🚀 Features

- ✅ Root user check
- ✅ Internet connectivity check
- ✅ Runs `apt update` + `full-upgrade` with **phased updates enabled**
- ✅ Auto `autoremove` + `autoclean` after upgrading
- ✅ Supports `--dry-run` mode
- ✅ Emoji-powered, color-coded terminal output for clarity & fun

---

## 🛠 Usage

### 1. 🔓 Make it executable:
```bash
chmod +x update.sh

Run with sudo
sudo ./update.sh

Dry Run mode
./update.sh --dry-run

How to make it global?
sudo mv update.sh /usr/local/bin/update

Now you can just run
sudo update

!!
