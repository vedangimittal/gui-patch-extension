# Auto setup script for Chrome/Edge on Windows
# Run this in PowerShell as a regular user (no admin needed)

$ErrorActionPreference = "Stop"

$EXTENSION_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$NATIVE_HOST_PATH = Join-Path $EXTENSION_DIR "native-host.py"
$CHROME_MANIFEST_DIR = "$env:LOCALAPPDATA\Google\Chrome\User Data\NativeMessagingHosts"
$EDGE_MANIFEST_DIR   = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\NativeMessagingHosts"

Write-Host "Setting up Remote Deployment extension for Chrome/Edge..." -ForegroundColor Cyan
Write-Host ""

# ── 1. Check Python 3 ─────────────────────────────────────────────────────────
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
    Write-Host "       Download it from https://www.python.org/ and make sure to tick 'Add to PATH'."
    exit 1
}

# ── 2. Check / install sshpass via winget ─────────────────────────────────────
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

# ── 3. Check native-host.py exists ────────────────────────────────────────────
if (-not (Test-Path $NATIVE_HOST_PATH)) {
    Write-Host "ERROR  native-host.py not found at: $NATIVE_HOST_PATH" -ForegroundColor Red
    exit 1
}
Write-Host "OK  native-host.py found" -ForegroundColor Green

# ── 4. Write manifests with placeholder ID ────────────────────────────────────
function Write-Manifest($dir) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $manifest = @{
        name             = "remote_deployment"
        description      = "Native messaging host for remote deployment"
        path             = $NATIVE_HOST_PATH
        type             = "stdio"
        allowed_origins  = @("chrome-extension://EXTENSION_ID_PLACEHOLDER/")
    } | ConvertTo-Json -Depth 5
    Set-Content -Path "$dir\remote_deployment.json" -Value $manifest -Encoding UTF8
    Write-Host "OK  Manifest written to: $dir\remote_deployment.json" -ForegroundColor Green
}

Write-Host "Creating native messaging manifests..."
Write-Manifest $CHROME_MANIFEST_DIR
Write-Manifest $EDGE_MANIFEST_DIR

# ── 5. Prompt for Extension ID and patch manifests ────────────────────────────
Write-Host ""
Write-Host "--------------------------------------------------------------"
Write-Host "  One manual step required:"
Write-Host ""
Write-Host "  1. Open Chrome and go to: chrome://extensions/"
Write-Host "  2. Turn on Developer mode (top-right toggle)"
Write-Host "  3. Click 'Load unpacked' -> select the build\chrome\ folder"
Write-Host "  4. Copy the Extension ID shown on the extension card"
Write-Host "--------------------------------------------------------------"
Write-Host ""
$EXT_ID = Read-Host "Paste the Extension ID here and press Enter"

if ([string]::IsNullOrWhiteSpace($EXT_ID)) {
    Write-Host ""
    Write-Host "WARN  No ID entered. Update the manifests manually later by replacing" -ForegroundColor Yellow
    Write-Host "      EXTENSION_ID_PLACEHOLDER in the files shown above."
} else {
    (Get-Content "$CHROME_MANIFEST_DIR\remote_deployment.json") -replace "EXTENSION_ID_PLACEHOLDER", $EXT_ID |
        Set-Content "$CHROME_MANIFEST_DIR\remote_deployment.json" -Encoding UTF8
    (Get-Content "$EDGE_MANIFEST_DIR\remote_deployment.json") -replace "EXTENSION_ID_PLACEHOLDER", $EXT_ID |
        Set-Content "$EDGE_MANIFEST_DIR\remote_deployment.json" -Encoding UTF8
    Write-Host "OK  Extension ID updated in both Chrome and Edge manifests" -ForegroundColor Green
}

# ── Done ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "All done! Restart Chrome, then click the extension icon -> 'Open side panel'." -ForegroundColor Green
Write-Host ""
Write-Host "If native messaging still doesn't work, make sure you restarted Chrome"
Write-Host "after this script finished."
