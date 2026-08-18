# Chrome Setup Guide

> **Edge users:** Follow the exact same steps — just use `edge://extensions/` wherever Chrome is mentioned.

> **Where to clone this repo:** The native host runs as a child process of Chrome/Edge and is subject to OS-level path restrictions.
>
> | Platform | Recommended path | Avoid |
> |---|---|---|
> | **macOS** | `~/Projects/extension-new` or `~/Developer/extension-new` | `~/Desktop`, `~/Documents`, `~/Downloads` (macOS TCC restrictions) |
> | **Linux** | `~/projects/extension-new` or any path under `$HOME` on a local filesystem | `/root/`, NFS/CIFS mounts |
> | **Windows** | `C:\Users\<you>\Projects\extension-new` on a local drive | `C:\Program Files\`, OneDrive folders, UNC paths |

---

## macOS / Linux

### Step 1 — Load the extension in Chrome and copy the Extension ID

Chrome needs a unique ID before native messaging can be registered.

1. Open Chrome and go to `chrome://extensions/`
2. Turn on **Developer mode** (toggle in the top-right corner)
3. Click **"Load unpacked"** → select the `build/chrome/` folder
4. Find the **Remote Deployment** card and copy the **Extension ID** shown underneath it (a long string of letters like `abcdefghijklmnopqrstuvwxyz123456`)

### Step 2 — Run the setup script

Open a terminal in the extension folder and run:

```bash
chmod +x auto-setup-chrome.sh && ./auto-setup-chrome.sh
```

The script will automatically:
- Install `sshpass` (via Homebrew on macOS, or `apt`/`dnf`/`yum` on Linux)
- Check that Python 3 is installed
- Make `native-host.py` executable
- Create the native messaging manifests for Chrome and Edge
- **Pause and ask you to paste the Extension ID** — paste the ID you copied in Step 1 and press Enter
- Automatically write the ID into both manifests (no file editing needed)

### Step 3 — Restart Chrome

Close and reopen Chrome so it picks up the updated manifest.

### Step 4 — Open the side panel and deploy

1. Click the **Remote Deployment** icon in the Chrome toolbar
2. Click **"Open side panel"**
3. Fill in your **project path**, **remote IP**, and **password**
4. Click **Deploy Build**

---

## Windows

### Step 1 — Load the extension in Chrome and copy the Extension ID

1. Open Chrome and go to `chrome://extensions/`
2. Turn on **Developer mode** (toggle in the top-right corner)
3. Click **"Load unpacked"** → select the `build\chrome\` folder
4. Copy the **Extension ID** shown on the extension card

### Step 2 — Run the setup script

Open **PowerShell** in the extension folder and run:

```powershell
.\auto-setup-chrome.ps1
```

> If you see a script execution error, run this first to allow local scripts:
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
> ```

The script will automatically:
- Check that Python 3 is installed
- Try to install `sshpass` via `winget`
- Create native messaging manifests for Chrome and Edge
- **Pause and ask you to paste the Extension ID** — paste the ID you copied in Step 1 and press Enter
- Automatically write the ID into both manifests (no file editing needed)

### Step 3 — Restart Chrome

Close and reopen Chrome so it picks up the updated manifest.

### Step 4 — Open the side panel and deploy

1. Click the **Remote Deployment** icon in the Chrome toolbar
2. Click **"Open side panel"**
3. Fill in your **project path**, **remote IP**, and **password**
4. Click **Deploy Build**

---

## Common Problems

**"Native messaging host not found"** — The Extension ID in the manifest is wrong or missing. Re-run `./auto-setup-chrome.sh` and paste the correct ID when prompted.

**Skipped the ID prompt** — Open the manifest file at `~/Library/Application Support/Google/Chrome/NativeMessagingHosts/remote_deployment.json` (macOS) or `~/.config/google-chrome/NativeMessagingHosts/remote_deployment.json` (Linux) and replace `EXTENSION_ID_PLACEHOLDER` with your Extension ID.

**Extension not in toolbar** — Click the puzzle-piece icon in Chrome and pin the extension.

**Deployment fails** — Make sure your project has a `package.json` with a `build` script and `npm` is installed.

**Check for errors** — Press `Ctrl+Shift+J` to open the browser console and look for errors related to `remote_deployment`.
