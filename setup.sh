#!/bin/bash
# Combined setup script for Chrome/Edge and Firefox (Linux/macOS)

set -e

EXTENSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NATIVE_HOST_PATH="$EXTENSION_DIR/native-host-wrapper.sh"

echo "🚀 Remote Deployment — Setup"
echo ""

# ── 1. Check Homebrew (macOS only) ───────────────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &> /dev/null; then
        echo "✅ Homebrew found"
    else
        echo "❌ Homebrew is not installed — required on macOS to install sshpass."
        echo "   Install it from: https://brew.sh/"
        echo "   Then re-run this script."
        exit 1
    fi
fi

# ── 2. Check & install sshpass ────────────────────────────────────────────────
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

# ── 3. Check npm / Node.js ───────────────────────────────────────────────────
if command -v npm &> /dev/null; then
    echo "✅ npm found: $(npm --version)"
else
    echo "❌ npm / Node.js is not installed or not on PATH."
    echo "   Download Node.js (includes npm) from: https://nodejs.org/"
    echo "   Then re-run this script."
    exit 1
fi

# ── 4. Check Python 3 ─────────────────────────────────────────────────────────
if command -v python3 &> /dev/null; then
    echo "✅ Python found: $(python3 --version)"
else
    echo "❌ Python 3 is not installed or not on PATH."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "   Install it via Homebrew:  brew install python3"
        echo "   Or download from:         https://www.python.org/"
    else
        echo "   Install it via your package manager, e.g.:"
        echo "     sudo apt install python3   (Debian/Ubuntu)"
        echo "     sudo dnf install python3   (Fedora/RHEL)"
        echo "   Or download from: https://www.python.org/"
    fi
    echo "   Then re-run this script."
    exit 1
fi

# ── 5. Make scripts executable ───────────────────────────────────────────────
if [ ! -f "$NATIVE_HOST_PATH" ]; then
    echo "❌ Error: native-host-wrapper.sh not found at $NATIVE_HOST_PATH"
    exit 1
fi
chmod 777 "$NATIVE_HOST_PATH"
chmod 777 "$EXTENSION_DIR/native-host.py"
chmod 777 "$EXTENSION_DIR/load-build.sh"
echo "✅ native-host-wrapper.sh, native-host.py and load-build.sh are executable"

# ── 6. Detect installed browsers ─────────────────────────────────────────────
HAS_CHROME=false
HAS_FIREFOX=false

if command -v google-chrome &> /dev/null || command -v google-chrome-stable &> /dev/null || \
   command -v chromium &> /dev/null || command -v chromium-browser &> /dev/null || \
   [ -d "/Applications/Google Chrome.app" ]; then
    HAS_CHROME=true
fi

if command -v firefox &> /dev/null || [ -d "/Applications/Firefox.app" ]; then
    HAS_FIREFOX=true
fi

if ! $HAS_CHROME && ! $HAS_FIREFOX; then
    echo "⚠️  Neither Chrome nor Firefox detected. Setting up for both anyway..."
    HAS_CHROME=true
    HAS_FIREFOX=true
fi

$HAS_CHROME && echo "🌐 Chrome/Edge detected"
$HAS_FIREFOX && echo "🦊 Firefox detected"
echo ""

# ── 7. Setup Chrome/Edge ──────────────────────────────────────────────────────
if $HAS_CHROME; then
    echo "── Setting up Chrome/Edge ──────────────────────────────────────"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        CHROME_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
        EDGE_DIR="$HOME/Library/Application Support/Microsoft Edge/NativeMessagingHosts"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        CHROME_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
        EDGE_DIR="$HOME/.config/microsoft-edge/NativeMessagingHosts"
    fi

    EXT_ID="fcdlbghgdaiamfbfbaadhnccijahgkoh"

    write_chrome_manifest() {
        local DIR=$1
        mkdir -p "$DIR"
        cat > "$DIR/remote_deployment.json" << EOF
{
  "name": "remote_deployment",
  "description": "Native messaging host for remote deployment",
  "path": "$NATIVE_HOST_PATH",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://$EXT_ID/"
  ]
}
EOF
        echo "✅ Manifest written to: $DIR/remote_deployment.json"
    }

    write_chrome_manifest "$CHROME_DIR"
    write_chrome_manifest "$EDGE_DIR"

    echo ""
    echo "──────────────────────────────────────────────────────────────"
    echo "  Load the extension in Chrome:"
    echo ""
    echo "  1. Open Chrome and go to: chrome://extensions/"
    echo "  2. Turn on Developer mode (top-right toggle)"
    echo "  3. Click 'Load unpacked' → select the build/chrome/ folder"
    echo "──────────────────────────────────────────────────────────────"
    echo ""
fi

# ── 8. Setup Firefox ──────────────────────────────────────────────────────────
if $HAS_FIREFOX; then
    echo "── Setting up Firefox ──────────────────────────────────────────"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        FF_DIR="$HOME/Library/Application Support/Mozilla/NativeMessagingHosts"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        FF_DIR="$HOME/.mozilla/native-messaging-hosts"
    fi

    mkdir -p "$FF_DIR"
    cat > "$FF_DIR/remote_deployment.json" << EOF
{
  "name": "remote_deployment",
  "description": "Native messaging host for remote deployment",
  "path": "$NATIVE_HOST_PATH",
  "type": "stdio",
  "allowed_extensions": ["remote-deployment@example.com"]
}
EOF
    echo "✅ Native messaging manifest written to: $FF_DIR/remote_deployment.json"

    # Auto-launch Firefox to install the .xpi
    XPI_PATH="$EXTENSION_DIR/build/firefox/b124edb8b1a842c5a6ef-1.0.0.xpi"
    if [ -f "$XPI_PATH" ]; then
        echo "📦 Opening Firefox to install the extension..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            open -a Firefox "$XPI_PATH"
        else
            firefox "$XPI_PATH" &
        fi
        echo "✅ Firefox opened — click 'Add' in the prompt to install the extension"
    else
        echo "⚠️  b124edb8b1a842c5a6ef-1.0.0.xpi not found at $XPI_PATH"
        echo "   Install manually: about:addons → gear icon → Install Add-on From File"
    fi
    echo ""
fi

# ── Done ─────────────────────────────────────────────────────────────────────
echo "✅ Setup complete!"
$HAS_CHROME && echo "   Chrome: restart the browser if it was already open"
$HAS_FIREFOX && echo "   Firefox: accept the install prompt that just opened"
