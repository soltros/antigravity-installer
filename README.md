# Antigravity Linux Installer

This is a bash script to install or update Antigravity system-wide on Linux.

## Requirements

- **Download Antigravity 2.0:** The script does not download the application for you. You must download the Antigravity 2.0 `.tar.gz` archive from [https://antigravity.google/download](https://antigravity.google/download).
- **Root access:** `sudo` is required to install files to `/opt` and `/usr/local/bin`.
- **System utilities:** Requires standard Linux commands (`tar`, `chmod`, `chown`, `mktemp`).

## Installation

1. Download the Antigravity 2.0 `.tar.gz` file.
2. Make the installer executable:
   ```bash
   chmod +x install.sh
   ```
3. Run the script with root privileges, passing the path to the tarball:
   ```bash
   sudo ./install.sh /path/to/Antigravity.tar.gz
   ```

## What the script does

1. Extracts the archive to a temporary folder.
2. Copies application files to `/opt/antigravity/` (removing older versions if present).
3. Sets correct permissions on `chrome-sandbox` (SUID bit).
4. Creates a symlink at `/usr/local/bin/antigravity` to allow launching from the terminal.
5. Adds a `.desktop` entry to `/usr/share/applications/antigravity.desktop` for application menus.

## Uninstallation

To remove Antigravity, delete the following files and directories:

```bash
sudo rm -rf /opt/antigravity
sudo rm -f /usr/local/bin/antigravity
sudo rm -f /usr/share/applications/antigravity.desktop
```
