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

---

## What it does

Enter your project path, remote IP, and password in the sidebar, click **Deploy Build**, and the extension builds your project and copies it to the remote machine. Output streams back in real-time.

---

## Setup

Run a single script — it auto-detects which browsers you have installed and sets up both.

### macOS / Linux

```bash
bash setup.sh
```

### Windows

```powershell
.\setup.ps1
```

> If you see a script execution error, run this first:
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
> ```

The script will:
- Install `sshpass` and verify Python 3
- Register the native messaging host for Chrome/Edge and/or Firefox
- **Firefox:** automatically open the `.xpi` install prompt — just click **Add**
- **Chrome/Edge:** prompt you to paste the Extension ID (see [CHROME-SETUP.md](CHROME-SETUP.md))

For detailed per-browser instructions see:
- [CHROME-SETUP.md](CHROME-SETUP.md)
- [FIREFOX-SETUP.md](FIREFOX-SETUP.md)

---

## Extension files

| Browser | File |
|---|---|
| Chrome / Edge | `build/chrome/chrome-extension.zip` |
| Firefox | `build/firefox/extension.xpi` |

---

## How it works

1. The sidebar collects your project path, remote IP, and password
2. The extension passes them to a local Python script via the browser's native messaging API
3. The Python script runs `load-build.sh`, which builds the project and SCPs the output to the remote machine
4. Output is streamed back to the sidebar in real-time
