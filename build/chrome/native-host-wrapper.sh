#!/bin/bash
# Wrapper script for native-host.py to work around macOS security restrictions

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Execute the Python script
exec /usr/bin/python3 "$SCRIPT_DIR/native-host.py" "$@"

