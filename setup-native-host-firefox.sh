#!/bin/bash
# Setup script for native messaging host

set -e

echo "🔧 Setting up native messaging host for Firefox..."

# Get the current directory (where the extension files are)
EXTENSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NATIVE_HOST_PATH="$EXTENSION_DIR/native-host.py"
MANIFEST_SOURCE="$EXTENSION_DIR/remote_deployment.json"

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

# Determine the Firefox native messaging directory based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    NATIVE_MESSAGING_DIR="$HOME/Library/Application Support/Mozilla/NativeMessagingHosts"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    NATIVE_MESSAGING_DIR="$HOME/.mozilla/native-messaging-hosts"
else
    echo "❌ Unsupported operating system: $OSTYPE"
    exit 1
fi

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
  "allowed_extensions": ["remote-deployment@example.com"]
}
EOF

echo "✅ Created native messaging manifest at: $MANIFEST_DEST"

# Verify the manifest
echo ""
echo "📋 Manifest contents:"
cat "$MANIFEST_DEST"
echo ""

# Check if Python 3 is available
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
echo "1. Load the extension in Firefox (about:debugging)"
echo "2. Open the sidebar (View > Sidebar > Remote Deployment)"
echo "3. Test the deployment"
echo ""
echo "If you still get errors, check the Browser Console (Ctrl+Shift+J) for details."

