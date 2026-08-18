# Remote Deployment Extension

Deploy builds to remote machines directly from your browser — supports Firefox, Chrome, and Edge.

---

## Getting Started

Clone the repo into one of the recommended locations below and move into the folder.

> **Where to clone:** The extension's native host runs as a child process of your browser and is subject to OS-level path restrictions. **Avoid** `~/Desktop`, `~/Documents`, `~/Downloads`, `C:\Program Files`, or any cloud-synced folder.
>
> | Platform | Recommended path |
> |---|---|
> | **macOS** | `~/Projects/extension` or `~/Developer/extension` |
> | **Linux** | `~/projects/extension` or any path under `$HOME` on a local filesystem |
> | **Windows** | `C:\Users\<you>\Projects\extension` on a local (non-OneDrive) drive |

Then follow the setup steps for your browser below.

---

## What it does

Enter your project path, remote IP, and password in the sidebar, click **Deploy Build**, and the extension builds your project and copies it to the remote machine. Output streams back in real-time.

---

## Setup

### Firefox
- **macOS / Linux:** run `chmod +x auto-setup-firefox.sh && ./auto-setup-firefox.sh`
- **Windows:** open PowerShell and run `.\auto-setup-firefox.ps1`

See [FIREFOX-SETUP.md](FIREFOX-SETUP.md) for full instructions.

### Chrome / Edge
- **macOS / Linux:** run `chmod +x auto-setup-chrome.sh && ./auto-setup-chrome.sh`
- **Windows:** open PowerShell and run `.\auto-setup-chrome.ps1`

See [CHROME-SETUP.md](CHROME-SETUP.md) for full instructions.

---

## How it works

1. The sidebar collects your project path, remote IP, and password
2. The extension passes them to a local Python script via the browser's native messaging API
3. The Python script runs `load-build.sh`, which builds the project and SCPs the output to the remote machine
4. Output is streamed back to the sidebar in real-time
