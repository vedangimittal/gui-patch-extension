#!/bin/bash
# Auto setup script for Firefox - installs dependencies and registers native messaging host

set -e

EXTENSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NATIVE_HOST_PATH="$EXTENSION_DIR/native-host.py"

echo "🦊 Setting up Remote Deployment extension for Firefox..."
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

# ── 4. Determine native messaging directory ───────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
    NATIVE_MESSAGING_DIR="$HOME/Library/Application Support/Mozilla/NativeMessagingHosts"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    NATIVE_MESSAGING_DIR="$HOME/.mozilla/native-messaging-hosts"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

# ── 5. Write the manifest ─────────────────────────────────────────────────────
mkdir -p "$NATIVE_MESSAGING_DIR"
MANIFEST_DEST="$NATIVE_MESSAGING_DIR/remote_deployment.json"

cat > "$MANIFEST_DEST" << EOF
{
  "name": "remote_deployment",
  "description": "Native messaging host for remote deployment",
  "path": "$NATIVE_HOST_PATH",
  "type": "stdio",
  "allowed_extensions": ["remote-deployment@example.com"]
}
EOF

echo "✅ Native messaging manifest written to: $MANIFEST_DEST"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "✅ All done! Now do two quick things in Firefox:"
echo ""
echo "  1. Go to: about:debugging#/runtime/this-firefox"
echo "  2. Click 'Load Temporary Add-on' and select any file in build/firefox/"
echo ""
echo "That's it — use the sidebar (View → Sidebar → Remote Deployment) to deploy."
