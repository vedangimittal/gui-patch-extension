# Auto setup script for Firefox on Windows
# Run this in PowerShell as a regular user (no admin needed)

$ErrorActionPreference = "Stop"

$EXTENSION_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$NATIVE_HOST_PATH = Join-Path $EXTENSION_DIR "native-host.py"
$MANIFEST_DIR = "$env:APPDATA\Mozilla\NativeMessagingHosts"
$MANIFEST_DEST = "$MANIFEST_DIR\remote_deployment.json"

Write-Host "Setting up Remote Deployment extension for Firefox..." -ForegroundColor Cyan
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

# ── 4. Write the native messaging manifest ────────────────────────────────────
Write-Host "Creating native messaging manifest..."
New-Item -ItemType Directory -Force -Path $MANIFEST_DIR | Out-Null

$manifest = @{
    name                = "remote_deployment"
    description         = "Native messaging host for remote deployment"
    path                = $NATIVE_HOST_PATH
    type                = "stdio"
    allowed_extensions  = @("remote-deployment@example.com")
} | ConvertTo-Json -Depth 5

Set-Content -Path $MANIFEST_DEST -Value $manifest -Encoding UTF8
Write-Host "OK  Manifest written to: $MANIFEST_DEST" -ForegroundColor Green

# ── Done ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "All done! Now do two quick things in Firefox:" -ForegroundColor Green
Write-Host ""
Write-Host "  1. Go to: about:debugging#/runtime/this-firefox"
Write-Host "  2. Click 'Load Temporary Add-on' and select any file in build\firefox\"
Write-Host ""
Write-Host "Then open the sidebar: View -> Sidebar -> Remote Deployment"
