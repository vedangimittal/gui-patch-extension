#!/bin/bash
# Automatic setup script - runs all commands automatically

set -e

# Install sshpass
brew install sshpass

# Make setup script executable and run it
chmod +x setup-native-host.sh
./setup-native-host.sh
