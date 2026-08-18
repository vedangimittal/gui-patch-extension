#!/bin/bash
# One-time setup: installs the native messaging host for Chrome/Edge
# Run this once after loading the extension in Chrome.
#
# Usage: ./install.sh [EXTENSION_ID]
#   EXTENSION_ID - the Chrome extension ID shown in chrome://extensions
#                  (if omitted, the script will prompt for it)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NATIVE_HOST_NAME="remote_deployment"
NATIVE_HOST_DIR="$HOME/Library/Application Support/remote-deployment"
CHROME_MANIFEST_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
EDGE_MANIFEST_DIR="$HOME/Library/Application Support/Microsoft Edge/NativeMessagingHosts"

# Get extension ID
EXT_ID="${1:-}"
if [ -z "$EXT_ID" ]; then
  echo ""
  echo "┌─────────────────────────────────────────────────────────┐"
  echo "│         Remote Deployment Tool — Native Host Setup      │"
  echo "└─────────────────────────────────────────────────────────┘"
  echo ""
  echo "Step 1: Open Chrome and go to: chrome://extensions"
  echo "Step 2: Enable 'Developer mode' (top-right toggle)"
  echo "Step 3: Click 'Load unpacked' and select this folder:"
  echo "        $SCRIPT_DIR"
  echo "Step 4: Copy the Extension ID shown under the extension name"
  echo ""
  read -p "Paste Extension ID here: " EXT_ID
fi

if [ -z "$EXT_ID" ]; then
  echo "❌ No extension ID provided. Exiting."
  exit 1
fi

echo ""
echo "📦 Installing native messaging host..."

# Create host directory and copy files
mkdir -p "$NATIVE_HOST_DIR"
cp "$SCRIPT_DIR/native-host.py" "$NATIVE_HOST_DIR/native-host.py"
cp "$SCRIPT_DIR/load-build.sh"  "$NATIVE_HOST_DIR/load-build.sh"
chmod +x "$NATIVE_HOST_DIR/native-host.py"
chmod +x "$NATIVE_HOST_DIR/load-build.sh"

# Write the native host manifest (with real path and real extension ID)
MANIFEST_CONTENT="{
  \"name\": \"remote_deployment\",
  \"description\": \"Native messaging host for Remote Deployment Tool\",
  \"path\": \"$NATIVE_HOST_DIR/native-host.py\",
  \"type\": \"stdio\",
  \"allowed_origins\": [
    \"chrome-extension://$EXT_ID/\"
  ]
}"

# Install for Chrome
if [ -d "$HOME/Library/Application Support/Google/Chrome" ] || [ "$FORCE_CHROME" = "1" ]; then
  mkdir -p "$CHROME_MANIFEST_DIR"
  echo "$MANIFEST_CONTENT" > "$CHROME_MANIFEST_DIR/${NATIVE_HOST_NAME}.json"
  echo "  ✅ Installed for Chrome: $CHROME_MANIFEST_DIR/${NATIVE_HOST_NAME}.json"
fi

# Install for Edge
if [ -d "$HOME/Library/Application Support/Microsoft Edge" ] || [ "$FORCE_EDGE" = "1" ]; then
  mkdir -p "$EDGE_MANIFEST_DIR"
  echo "$MANIFEST_CONTENT" > "$EDGE_MANIFEST_DIR/${NATIVE_HOST_NAME}.json"
  echo "  ✅ Installed for Edge:   $EDGE_MANIFEST_DIR/${NATIVE_HOST_NAME}.json"
fi

# Verify python3 available
if ! command -v python3 &>/dev/null; then
  echo ""
  echo "⚠️  python3 not found. The native host requires Python 3."
  echo "   Install it with: brew install python"
  exit 1
fi

# Verify sshpass available
if ! command -v sshpass &>/dev/null; then
  echo ""
  echo "⚠️  sshpass not found. Required for deployment over SSH."
  echo "   Install it with: brew install sshpass"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next: Reload the extension in Chrome (chrome://extensions → click the"
echo "      reload icon under Remote Deployment Tool), then click the extension"
echo "      icon to deploy."
