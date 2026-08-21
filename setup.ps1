# Combined setup script for Chrome/Edge and Firefox (Windows)
# Run this in PowerShell as a regular user (no admin needed)

$ErrorActionPreference = "Stop"

$EXTENSION_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$NATIVE_HOST_PATH = Join-Path $EXTENSION_DIR "native-host-wrapper.sh"

Write-Host "Remote Deployment - Setup" -ForegroundColor Cyan
Write-Host ""

# ── 1. Check npm / Node.js ───────────────────────────────────────────────────
Write-Host "Checking for npm / Node.js..."
if (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Host "OK  npm found: $(npm --version)" -ForegroundColor Green
} else {
    Write-Host "ERROR  npm / Node.js is not installed or not on PATH." -ForegroundColor Red
    Write-Host "       Download Node.js (includes npm) from: https://nodejs.org/"
    Write-Host "       Tick 'Add to PATH' during install, then re-run this script."
    exit 1
}

# ── 2. Check Python 3 ─────────────────────────────────────────────────────────
Write-Host "Checking for Python 3..."
try {
    $pyVersion = python --version 2>&1
    if ($pyVersion -match "Python 3") {
        Write-Host "OK  Python found: $pyVersion" -ForegroundColor Green
    } else {
        throw "Python 3 not found"
    }
} catch {
    Write-Host "ERROR  Python 3 is not installed or not on PATH." -ForegroundColor Red
    Write-Host "       Download it from https://www.python.org/ and tick 'Add to PATH'."
    Write-Host "       Then re-run this script."
    exit 1
}

# ── 3. Check / install sshpass via winget ─────────────────────────────────────
Write-Host "Checking for sshpass..."
if (Get-Command sshpass -ErrorAction SilentlyContinue) {
    Write-Host "OK  sshpass already installed" -ForegroundColor Green
} else {
    Write-Host "sshpass not found. Trying to install via winget..."
    try {
        winget install -e --id ShiftLeft.sshpass --accept-package-agreements --accept-source-agreements
        Write-Host "OK  sshpass installed" -ForegroundColor Green
    } catch {
        Write-Host "WARN  Could not install sshpass automatically." -ForegroundColor Yellow
        Write-Host "      If deployment fails, install it manually or use SSH keys instead."
    }
}

# ── 4. Check native-host.py exists ────────────────────────────────────────────
if (-not (Test-Path $NATIVE_HOST_PATH)) {
    Write-Host "ERROR  native-host-wrapper.sh not found at: $NATIVE_HOST_PATH" -ForegroundColor Red
    exit 1
}
Write-Host "OK  native-host-wrapper.sh found" -ForegroundColor Green

# Grant execute permissions to load-build.sh
$LOAD_BUILD_PATH = Join-Path $EXTENSION_DIR "load-build.sh"
if (Test-Path $LOAD_BUILD_PATH) {
    icacls $LOAD_BUILD_PATH /grant Everyone:F | Out-Null
    Write-Host "OK  load-build.sh permissions set" -ForegroundColor Green
}
Write-Host ""

# ── 5. Detect installed browsers ─────────────────────────────────────────────
$HAS_CHROME = (Test-Path "$env:PROGRAMFILES\Google\Chrome\Application\chrome.exe") -or
              (Test-Path "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe")
$HAS_FIREFOX = (Test-Path "$env:PROGRAMFILES\Mozilla Firefox\firefox.exe") -or
               (Test-Path "$env:PROGRAMFILES(x86)\Mozilla Firefox\firefox.exe")

if (-not $HAS_CHROME -and -not $HAS_FIREFOX) {
    Write-Host "WARN  Neither Chrome nor Firefox detected. Setting up for both anyway..." -ForegroundColor Yellow
    $HAS_CHROME = $true
    $HAS_FIREFOX = $true
}

if ($HAS_CHROME)  { Write-Host "Chrome/Edge detected" -ForegroundColor Green }
if ($HAS_FIREFOX) { Write-Host "Firefox detected" -ForegroundColor Green }
Write-Host ""

# ── 6. Setup Chrome/Edge ──────────────────────────────────────────────────────
if ($HAS_CHROME) {
    Write-Host "-- Setting up Chrome/Edge --" -ForegroundColor Cyan

    $CHROME_MANIFEST_DIR = "$env:LOCALAPPDATA\Google\Chrome\User Data\NativeMessagingHosts"
    $EDGE_MANIFEST_DIR   = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\NativeMessagingHosts"

    $EXT_ID = "fcdlbghgdaiamfbfbaadhnccijahgkoh"

    function Write-ChromeManifest($dir) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        $manifest = @{
            name             = "remote_deployment"
            description      = "Native messaging host for remote deployment"
            path             = $NATIVE_HOST_PATH
            type             = "stdio"
            allowed_origins  = @("chrome-extension://$EXT_ID/")
        } | ConvertTo-Json -Depth 5
        Set-Content -Path "$dir\remote_deployment.json" -Value $manifest -Encoding UTF8
        Write-Host "OK  Manifest written to: $dir\remote_deployment.json" -ForegroundColor Green
    }

    Write-ChromeManifest $CHROME_MANIFEST_DIR
    Write-ChromeManifest $EDGE_MANIFEST_DIR

    Write-Host ""
    Write-Host "--------------------------------------------------------------"
    Write-Host "  Load the extension in Chrome:"
    Write-Host ""
    Write-Host "  1. Open Chrome and go to: chrome://extensions/"
    Write-Host "  2. Turn on Developer mode (top-right toggle)"
    Write-Host "  3. Click 'Load unpacked' -> select the build\chrome\ folder"
    Write-Host "--------------------------------------------------------------"
    Write-Host ""
}

# ── 7. Setup Firefox ──────────────────────────────────────────────────────────
if ($HAS_FIREFOX) {
    Write-Host "-- Setting up Firefox --" -ForegroundColor Cyan

    $FF_MANIFEST_DIR  = "$env:APPDATA\Mozilla\NativeMessagingHosts"
    $FF_MANIFEST_DEST = "$FF_MANIFEST_DIR\remote_deployment.json"

    New-Item -ItemType Directory -Force -Path $FF_MANIFEST_DIR | Out-Null
    $ffManifest = @{
        name                = "remote_deployment"
        description         = "Native messaging host for remote deployment"
        path                = $NATIVE_HOST_PATH
        type                = "stdio"
        allowed_extensions  = @("remote-deployment@example.com")
    } | ConvertTo-Json -Depth 5
    Set-Content -Path $FF_MANIFEST_DEST -Value $ffManifest -Encoding UTF8
    Write-Host "OK  Manifest written to: $FF_MANIFEST_DEST" -ForegroundColor Green

    # Auto-launch Firefox to install the .xpi
    $XPI_PATH = Join-Path $EXTENSION_DIR "build\firefox\b124edb8b1a842c5a6ef-1.0.0.xpi"
    if (Test-Path $XPI_PATH) {
        Write-Host "Opening Firefox to install the extension..."
        if (Test-Path "$env:PROGRAMFILES\Mozilla Firefox\firefox.exe") {
            Start-Process "$env:PROGRAMFILES\Mozilla Firefox\firefox.exe" -ArgumentList $XPI_PATH
        } else {
            Start-Process "$env:PROGRAMFILES(x86)\Mozilla Firefox\firefox.exe" -ArgumentList $XPI_PATH
        }
        Write-Host "OK  Firefox opened - click 'Add' in the prompt to install the extension" -ForegroundColor Green
    } else {
        Write-Host "WARN  b124edb8b1a842c5a6ef-1.0.0.xpi not found at: $XPI_PATH" -ForegroundColor Yellow
        Write-Host "      Install manually: about:addons -> gear icon -> Install Add-on From File"
    }
    Write-Host ""
}

# ── Done ──────────────────────────────────────────────────────────────────────
Write-Host "Setup complete!" -ForegroundColor Green
if ($HAS_CHROME)  { Write-Host "   Chrome: restart the browser if it was already open" }
if ($HAS_FIREFOX) { Write-Host "   Firefox: accept the install prompt that just opened" }
