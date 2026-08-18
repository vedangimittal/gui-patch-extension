#!/bin/bash
# Auto setup script for Chrome/Edge - installs dependencies and registers native messaging host

set -e

EXTENSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NATIVE_HOST_PATH="$EXTENSION_DIR/native-host.py"

echo "🌐 Setting up Remote Deployment extension for Chrome/Edge..."
echo ""

# ── 1. Install sshpass ────────────────────────────────────────────────────────
if command -v sshpass &> /dev/null; then
    echo "✅ sshpass already installed"
else
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "📦 Installing sshpass via Homebrew..."
        brew install sshpass
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "📦 Installing sshpass..."
        if command -v apt &> /dev/null; then
            sudo apt install -y sshpass
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y sshpass
        elif command -v yum &> /dev/null; then
            sudo yum install -y sshpass
        else
            echo "⚠️  Could not detect package manager. Install sshpass manually."
        fi
    else
        echo "⚠️  Unsupported OS for automatic sshpass install. Install it manually."
    fi
fi

# ── 2. Check Python 3 ─────────────────────────────────────────────────────────
if command -v python3 &> /dev/null; then
    echo "✅ Python found: $(python3 --version)"
else
    echo "⚠️  python3 not found. Please install Python 3 and re-run this script."
    exit 1
fi

# ── 3. Make native-host.py executable ────────────────────────────────────────
if [ ! -f "$NATIVE_HOST_PATH" ]; then
    echo "❌ Error: native-host.py not found at $NATIVE_HOST_PATH"
    exit 1
fi
chmod +x "$NATIVE_HOST_PATH"
echo "✅ native-host.py is executable"

# ── 4. Determine native messaging directories ─────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
    CHROME_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
    EDGE_DIR="$HOME/Library/Application Support/Microsoft Edge/NativeMessagingHosts"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CHROME_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
    EDGE_DIR="$HOME/.config/microsoft-edge/NativeMessagingHosts"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

# ── 5. Write manifests (placeholder ID — updated in step 6) ──────────────────
write_manifest() {
    local DIR=$1
    mkdir -p "$DIR"
    cat > "$DIR/remote_deployment.json" << EOF
{
  "name": "remote_deployment",
  "description": "Native messaging host for remote deployment",
  "path": "$NATIVE_HOST_PATH",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://EXTENSION_ID_PLACEHOLDER/"
  ]
}
EOF
    echo "✅ Manifest written to: $DIR/remote_deployment.json"
}

write_manifest "$CHROME_DIR"
write_manifest "$EDGE_DIR"

# ── 6. Prompt user for Extension ID and patch manifests ───────────────────────
echo ""
echo "──────────────────────────────────────────────────────────────"
echo "  One manual step required:"
echo ""
echo "  1. Open Chrome and go to: chrome://extensions/"
echo "  2. Turn on Developer mode (top-right toggle)"
echo "  3. Click 'Load unpacked' → select the build/chrome/ folder"
echo "  4. Copy the Extension ID shown on the extension card"
echo "──────────────────────────────────────────────────────────────"
echo ""
read -p "Paste the Extension ID here and press Enter: " EXT_ID

if [ -z "$EXT_ID" ]; then
    echo "⚠️  No ID entered. You can update it manually later by replacing"
    echo "   EXTENSION_ID_PLACEHOLDER in the manifest files shown above."
else
    # Replace placeholder in both manifests
    sed -i.bak "s/EXTENSION_ID_PLACEHOLDER/$EXT_ID/g" "$CHROME_DIR/remote_deployment.json" && rm -f "$CHROME_DIR/remote_deployment.json.bak"
    sed -i.bak "s/EXTENSION_ID_PLACEHOLDER/$EXT_ID/g" "$EDGE_DIR/remote_deployment.json" && rm -f "$EDGE_DIR/remote_deployment.json.bak"
    echo "✅ Extension ID updated in both Chrome and Edge manifests"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "✅ All done! Restart Chrome, then click the extension icon → 'Open side panel'."
echo ""
echo "If native messaging still doesn't work, make sure you restarted Chrome"
echo "after this script finished."
