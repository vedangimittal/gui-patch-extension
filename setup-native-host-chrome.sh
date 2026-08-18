#!/bin/bash
# Setup script for native messaging host for Chrome/Edge

set -e

echo "🔧 Setting up native messaging host for Chrome/Edge..."

# Get the current directory (where the extension files are)
EXTENSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NATIVE_HOST_PATH="$EXTENSION_DIR/native-host.py"

echo "Extension directory: $EXTENSION_DIR"
echo "Native host path: $NATIVE_HOST_PATH"

# Check if native-host.py exists
if [ ! -f "$NATIVE_HOST_PATH" ]; then
    echo "❌ Error: native-host.py not found at $NATIVE_HOST_PATH"
    exit 1
fi

# Make native-host.py executable
chmod +x "$NATIVE_HOST_PATH"
echo "✅ Made native-host.py executable"

# Determine the Chrome/Edge native messaging directory based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CHROME_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
    EDGE_DIR="$HOME/Library/Application Support/Microsoft Edge/NativeMessagingHosts"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    CHROME_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
    EDGE_DIR="$HOME/.config/microsoft-edge/NativeMessagingHosts"
else
    echo "❌ Unsupported operating system: $OSTYPE"
    exit 1
fi

# Function to setup for a browser
setup_browser() {
    local BROWSER_NAME=$1
    local NATIVE_MESSAGING_DIR=$2
    
    echo ""
    echo "Setting up for $BROWSER_NAME..."
    echo "Native messaging directory: $NATIVE_MESSAGING_DIR"
    
    # Create the directory if it doesn't exist
    mkdir -p "$NATIVE_MESSAGING_DIR"
    echo "✅ Created native messaging directory"
    
    # Create the manifest file with the correct path
    MANIFEST_DEST="$NATIVE_MESSAGING_DIR/remote_deployment.json"
    
    cat > "$MANIFEST_DEST" << EOF
{
  "name": "remote_deployment",
  "description": "Native messaging host for remote deployment",
  "path": "$NATIVE_HOST_PATH",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://YOUR_EXTENSION_ID_HERE/"
  ]
}
EOF
    
    echo "✅ Created native messaging manifest at: $MANIFEST_DEST"
    echo ""
    echo "⚠️  IMPORTANT: You need to update the extension ID in:"
    echo "   $MANIFEST_DEST"
    echo ""
    echo "   Replace YOUR_EXTENSION_ID_HERE with your actual extension ID from:"
    echo "   - Chrome: chrome://extensions/"
    echo "   - Edge: edge://extensions/"
}

# Setup for Chrome
setup_browser "Chrome" "$CHROME_DIR"

# Setup for Edge
setup_browser "Edge" "$EDGE_DIR"

# Check if Python 3 is available
echo ""
if ! command -v python3 &> /dev/null; then
    echo "⚠️  Warning: python3 not found. Make sure Python 3 is installed."
else
    PYTHON_VERSION=$(python3 --version)
    echo "✅ Python found: $PYTHON_VERSION"
fi

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "⚠️  Warning: sshpass not found. Install it with: brew install sshpass"
else
    echo "✅ sshpass is installed"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Load the extension in Chrome/Edge"
echo "2. Copy the extension ID from chrome://extensions/ or edge://extensions/"
echo "3. Update the 'allowed_origins' in the manifest files with your extension ID"
echo "4. Restart the browser"
echo "5. Test the deployment"
echo ""
