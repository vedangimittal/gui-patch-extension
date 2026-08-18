# Firefox Setup Guide

> **Where to clone this repo:** The native host runs as a child process of Firefox and is subject to OS-level path restrictions.
>
> | Platform | Recommended path | Avoid |
> |---|---|---|
> | **macOS** | `~/Projects/extension` or `~/Developer/extension` | `~/Desktop`, `~/Documents`, `~/Downloads` (macOS TCC restrictions) |
> | **Linux** | `~/projects/extension` or any path under `$HOME` on a local filesystem | `/root/`, NFS/CIFS mounts |
> | **Windows** | `C:\Users\<you>\Projects\extension` on a local drive | `C:\Program Files\`, OneDrive folders, UNC paths |

---

## macOS / Linux

### Step 1 — Run the setup script

Open a terminal in the extension folder and run:

```bash
chmod +x auto-setup-firefox.sh && ./auto-setup-firefox.sh
```

The script will automatically:
- Install `sshpass` (via Homebrew on macOS, or `apt`/`dnf`/`yum` on Linux)
- Check that Python 3 is installed
- Make `native-host.py` executable
- Create the native messaging manifest so Firefox can talk to the extension

### Step 2 — Load the extension in Firefox

1. Open Firefox and go to `about:debugging#/runtime/this-firefox`
2. Click **"Load Temporary Add-on..."**
3. Select any file inside the `build/firefox/` folder

### Step 3 — Open the sidebar and deploy

1. In Firefox, go to **View → Sidebar → Remote Deployment**
2. Fill in your **project path**, **remote IP**, and **password**
3. Click **Deploy Build**

> **Note:** Temporary add-ons are removed when Firefox restarts — reload from `about:debugging` each time.

---

## Windows

### Step 1 — Run the setup script

Open **PowerShell** in the extension folder and run:

```powershell
.\auto-setup-firefox.ps1
```

> If you see a script execution error, run this first to allow local scripts:
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
> ```

The script will automatically:
- Check that Python 3 is installed
- Try to install `sshpass` via `winget`
- Create the native messaging manifest so Firefox can talk to the extension

### Step 2 — Load the extension in Firefox

1. Open Firefox and go to `about:debugging#/runtime/this-firefox`
2. Click **"Load Temporary Add-on..."**
3. Select any file inside the `build\firefox\` folder

### Step 3 — Open the sidebar and deploy

1. In Firefox, go to **View → Sidebar → Remote Deployment**
2. Fill in your **project path**, **remote IP**, and **password**
3. Click **Deploy Build**

---

## Common Problems

**Extension disappears after restart** — Temporary add-ons don't survive browser restarts. Reload from `about:debugging`.

**"No such native application"** — Re-run `./auto-setup-firefox.sh`. On Windows, double-check the path in `remote_deployment.json`.

**"python3 not found"** — Install Python 3 and re-run the script.

**Deployment fails** — Make sure your project has a `package.json` with a `build` script and `npm` is installed.

**Check for errors** — Press `Ctrl+Shift+J` (or `Cmd+Shift+J` on Mac) to open the browser console.
