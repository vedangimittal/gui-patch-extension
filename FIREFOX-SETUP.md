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
bash setup.sh
```

The script will automatically:
- Install `sshpass` (via Homebrew on macOS, or `apt`/`dnf`/`yum` on Linux)
- Check that Python 3 is installed
- Make `native-host.py` executable
- Create the native messaging manifest so Firefox can talk to the extension
- **Open Firefox and prompt you to install the extension** — click **Add** to confirm

### Step 2 — Open the sidebar and deploy

1. In Firefox, go to **View → Sidebar → Remote Deployment**
2. Fill in your **project path**, **remote IP**, and **password**
3. Click **Deploy Build**

That's it — the extension persists across Firefox restarts.

---

## Windows

### Step 1 — Run the setup script

Open **PowerShell** in the extension folder and run:

```powershell
.\setup.ps1
```

> If you see a script execution error, run this first to allow local scripts:
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
> ```

The script will automatically:
- Check that Python 3 is installed
- Try to install `sshpass` via `winget`
- Create the native messaging manifest so Firefox can talk to the extension
- **Open Firefox and prompt you to install the extension** — click **Add** to confirm

### Step 2 — Open the sidebar and deploy

1. In Firefox, go to **View → Sidebar → Remote Deployment**
2. Fill in your **project path**, **remote IP**, and **password**
3. Click **Deploy Build**

---

## Manual installation (if the script doesn't open Firefox automatically)

**Option A — Drag and drop:**
1. Open a new tab in Firefox
2. Drag `build/firefox/b124edb8b1a842c5a6ef-1.0.0.xpi` from Finder/Explorer and drop it onto the new tab
3. Click **Add** in the prompt that appears

**Option B — Install from file:**
1. Open Firefox and go to `about:addons`
2. Click the gear icon → **Install Add-on From File**
3. Select `build/firefox/b124edb8b1a842c5a6ef-1.0.0.xpi`
4. Click **Add** in the prompt

---

## Common Problems

**"No such native application"** — Re-run `bash setup.sh` (or `.\setup.ps1` on Windows). On Windows, double-check the path in `%APPDATA%\Mozilla\NativeMessagingHosts\remote_deployment.json`.

**Extension not visible in sidebar menu** — Go to **View → Sidebar** and check if **Remote Deployment** appears. If not, reinstall the `.xpi`.

**"python3 not found"** — Install Python 3 and re-run the script.

**Deployment fails** — Make sure your project has a `package.json` with a `build` script and `npm` is installed.

**Check for errors** — Press `Ctrl+Shift+J` (or `Cmd+Shift+J` on Mac) to open the browser console.
